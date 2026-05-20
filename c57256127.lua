--Shipping Archfiend
-- 效果：
-- 可以以场上的表侧表示怪兽任意数量为对象，宣言1个种族或属性；那些怪兽变成那个种族或属性。
-- 这张卡在怪兽区域存在的状态，对方场上有怪兽特殊召唤的场合（伤害步骤除外）：可以以双方场上的种族·属性相同的怪兽各1只为对象；那些怪兽回到手卡。
-- 「配对恶魔」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 初始化函数，注册卡片效果
function s.initial_effect(c)
	-- 可以以场上的表侧表示怪兽任意数量为对象，宣言1个种族或属性；那些怪兽变成那个种族或属性。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"变更种族/属性"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.artg)
	e1:SetOperation(s.arop)
	c:RegisterEffect(e1)
	-- 这张卡在怪兽区域存在的状态，对方场上有怪兽特殊召唤的场合（伤害步骤除外）：可以以双方场上的种族·属性相同的怪兽各1只为对象；那些怪兽回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回到手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤场上表侧表示且可以成为效果对象的怪兽
function s.arfilter(c,e)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e)
end
-- 检查选中的怪兽组是否存在可以宣言的共同属性或种族
function s.gcheck(g)
	local att=ATTRIBUTE_ALL
	local race=ATTRIBUTE_ALL
	-- 遍历选中的怪兽组，计算它们属性和种族的按位与交集
	for tc in aux.Next(g) do
		att=bit.band(att,tc:GetAttribute())
		race=bit.band(race,tc:GetRace())
	end
	return att~=ATTRIBUTE_ALL or race~=RACE_ALL
end
-- 检查怪兽当前的属性或种族是否与宣言的值不同
function s.chkcfilter(c,op,val)
	if op==1 then
		return not c:IsAttribute(val)
	else
		return not c:IsRace(val)
	end
end
-- 效果1的发动准备：选择场上任意数量的表侧表示怪兽，并宣言1个种族或属性
function s.artg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取双方场上所有可以成为效果对象的表侧表示怪兽
	local tg=Duel.GetMatchingGroup(s.arfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	if chkc then
		local op,val=e:GetLabel()
		return chkc:IsType(TYPE_MONSTER) and chkc:IsFaceup() and s.chkcfilter(chkc,op,val)
	end
	if chk==0 then return tg:CheckSubGroup(s.gcheck,1,99) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local g=tg:SelectSubGroup(tp,s.gcheck,false,1,99)
	local att=ATTRIBUTE_ALL
	local race=ATTRIBUTE_ALL
	-- 遍历选中的对象怪兽，计算它们属性和种族的按位与交集
	for tc in aux.Next(g) do
		att=bit.band(att,tc:GetAttribute())
		race=bit.band(race,tc:GetRace())
	end
	local b1=att~=ATTRIBUTE_ALL
	local b2=race~=RACE_ALL
	-- 让玩家选择是宣言属性还是宣言种族
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},  --"宣言属性"
			{b2,aux.Stringid(id,3),2})  --"宣言种族"
	local var=0
	if op==1 then
		-- 提示玩家选择要宣言的属性
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
		-- 让玩家宣言1个不属于选中怪兽共同属性的属性
		var=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL-att)
	elseif op==2 then
		-- 提示玩家选择要宣言的种族
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
		-- 让玩家宣言1个不属于选中怪兽共同种族的种族
		var=Duel.AnnounceRace(tp,1,RACE_ALL-race)
	end
	e:SetLabel(op,var)
	-- 将选中的怪兽设置为效果的对象
	Duel.SetTargetCard(g)
end
-- 效果1的处理：将作为对象的怪兽变成宣言的种族或属性
function s.arop(e,tp,eg,ep,ev,re,r,rp)
	-- 过滤出仍留在场上且表侧表示的对象怪兽
	local tg=Duel.GetTargetsRelateToChain():Filter(Card.IsFaceup,nil)
	local c=e:GetHandler()
	local op,val=e:GetLabel()
	if op==1 then
		-- 遍历对象怪兽，准备改变其属性
		for tc in aux.Next(tg) do
			-- 那些怪兽变成那个属性
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e1:SetValue(val)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	elseif op==2 then
		-- 遍历对象怪兽，准备改变其种族
		for tc in aux.Next(tg) do
			-- 那些怪兽变成那个种族
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_RACE)
			e1:SetValue(val)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
-- 效果2的发动条件：对方场上有怪兽特殊召唤的场合
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp)
end
-- 过滤场上可以成为效果对象且能回到手卡的表侧表示怪兽
function s.thfilter(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsFaceup() and c:IsAbleToHand() and c:IsCanBeEffectTarget(e)
end
-- 检查选中的2只怪兽是否满足种族和属性相同，且分别属于双方玩家
function s.fselect(g)
	-- 检查怪兽组的属性和种族是否全部相同，且控制者数量为2（即双方场上各1只）
	return aux.SameValueCheck(g,Card.GetAttribute) and aux.SameValueCheck(g,Card.GetRace) and g:GetClassCount(Card.GetControler)==2
end
-- 效果2的发动准备：以双方场上的种族·属性相同的怪兽各1只为对象
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取双方场上所有可以成为效果对象且能回到手卡的表侧表示怪兽
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	if chkc then return false end
	if chk==0 then return g:CheckSubGroup(s.fselect,2,2) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local sg=g:SelectSubGroup(tp,s.fselect,false,2,2)
	-- 将选中的双方场上种族·属性相同的怪兽设置为效果的对象
	Duel.SetTargetCard(sg)
	-- 设置将怪兽送回手牌的效果分类和操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果2的处理：将作为对象的怪兽回到手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取仍与该连锁相关的对象怪兽
	local g=Duel.GetTargetsRelateToChain()
	if g:GetCount()>0 then
		-- 将对象怪兽送回持有者的手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
