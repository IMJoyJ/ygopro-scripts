--カップリング・デーモン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以场上的表侧表示怪兽任意数量为对象，宣言1个种族或属性才能发动。那些怪兽变成宣言的种族或属性。
-- ②：这张卡在怪兽区域存在的状态，对方场上有怪兽特殊召唤的场合，以自己以及对方场上的种族和属性相同的怪兽各1只为对象才能发动。那些怪兽回到手卡。
local s,id,o=GetID()
-- 初始化函数：注册效果e1（①起动效果，怪兽区域取对象发动，1回合1次，变更种族/属性）和效果e2（②对方场上特殊召唤成功时诱发的选发效果，怪兽区域取对象，1回合1次，让怪兽回到手卡）
function s.initial_effect(c)
	-- ①：以场上的表侧表示怪兽任意数量为对象，宣言1个种族或属性才能发动。那些怪兽变成宣言的种族或属性。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"变更种族/属性"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.artg)
	e1:SetOperation(s.arop)
	c:RegisterEffect(e1)
	-- ②：这张卡在怪兽区域存在的状态，对方场上有怪兽特殊召唤的场合，以自己以及对方场上的种族和属性相同的怪兽各1只为对象才能发动。那些怪兽回到手卡。
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
-- 过滤函数：筛选场上表侧表示且可以成为这个效果对象的怪兽
function s.arfilter(c,e)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e)
end
-- 子卡组检查函数：计算所选怪兽组中全体的属性位掩码交集与种族位掩码交集，若全体怪兽存在共同属性或共同种族则该组合有效
function s.gcheck(g)
	local att=ATTRIBUTE_ALL
	local race=ATTRIBUTE_ALL
	-- 遍历选中的每张怪兽，逐个累加属性和种族的位掩码交集
	for tc in aux.Next(g) do
		att=bit.band(att,tc:GetAttribute())
		race=bit.band(race,tc:GetRace())
	end
	return att~=ATTRIBUTE_ALL or race~=RACE_ALL
end
-- 对象候选检查函数：若宣言的是属性，则排除属性已为宣言值的卡；若宣言的是种族，则排除种族已为宣言值的卡
function s.chkcfilter(c,op,val)
	if op==1 then
		return not c:IsAttribute(val)
	else
		return not c:IsRace(val)
	end
end
-- ①效果的对象函数：取得场上可作对象的表侧表示怪兽组；发动条件检查是否存在满足共同属性或种族的1～99只子组合；让玩家选择1～99只满足条件的怪兽，计算这组怪兽的共同属性交集和共同种族交集，让玩家选择宣言属性还是种族，再从可宣言的范围内宣言1个属性或种族，记录选择结果并设置对象
function s.artg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 取得双方场上所有表侧表示且可以成为效果对象的怪兽组
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
	-- 遍历选中的每张怪兽，逐个累加其属性与种族的位掩码交集
	for tc in aux.Next(g) do
		att=bit.band(att,tc:GetAttribute())
		race=bit.band(race,tc:GetRace())
	end
	local b1=att~=ATTRIBUTE_ALL
	local b2=race~=RACE_ALL
	-- 让玩家在「宣言属性」（需存在共同属性）和「宣言种族」（需存在共同种族）两个有效选项中选择一个
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},  --"宣言属性"
			{b2,aux.Stringid(id,3),2})  --"宣言种族"
	local var=0
	if op==1 then
		-- 提示玩家选择要宣言的属性
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
		-- 让玩家从全属性中排除所选怪兽已有共同属性后的范围内，宣言1个属性
		var=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL-att)
	elseif op==2 then
		-- 提示玩家选择要宣言的种族
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
		-- 让玩家从全种族中排除所选怪兽已有共同种族后的范围内，宣言1个种族
		var=Duel.AnnounceRace(tp,1,RACE_ALL-race)
	end
	e:SetLabel(op,var)
	-- 把选中的怪兽组设置为当前连锁处理的对象
	Duel.SetTargetCard(g)
end
-- ①效果的处理：取得与本连锁关联的对象中表侧表示的怪兽；根据记录的选择，若为宣言属性则给每只怪兽注册不可无效的改变属性永续效果（变更为宣言的属性），若为宣言种族则给每只怪兽注册不可无效的改变种族永续效果（变更为宣言的种族）
function s.arop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得与本连锁关联的对象卡中仍为表侧表示的怪兽组
	local tg=Duel.GetTargetsRelateToChain():Filter(Card.IsFaceup,nil)
	local c=e:GetHandler()
	local op,val=e:GetLabel()
	if op==1 then
		-- 遍历对象怪兽，给每只怪兽注册改变属性的永续效果
		for tc in aux.Next(tg) do
			-- 那些怪兽变成宣言的属性。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e1:SetValue(val)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	elseif op==2 then
		-- 遍历对象怪兽，给每只怪兽注册改变种族的永续效果
		for tc in aux.Next(tg) do
			-- 那些怪兽变成宣言的种族。
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
-- ②效果的发动条件：特殊召唤成功的怪兽中存在对方控制的怪兽
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp)
end
-- 过滤函数：筛选场上表侧表示、可以回到手卡且可以成为效果对象的怪兽
function s.thfilter(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsFaceup() and c:IsAbleToHand() and c:IsCanBeEffectTarget(e)
end
-- 选择检查函数：选中的2只怪兽必须是种族和属性都相同，且分别属于己方和对方场上各1只
function s.fselect(g)
	-- 检查组内2只怪兽的属性交集和种族交集都不为空（即种族和属性相同），并且控制者恰有2种（即双方场上各1只）
	return aux.SameValueCheck(g,Card.GetAttribute) and aux.SameValueCheck(g,Card.GetRace) and g:GetClassCount(Card.GetControler)==2
end
-- ②效果的对象函数：取得双方场上可作对象的表侧表示怪兽组；发动条件检查是否存在满足「种族和属性相同且双方各1只」的2只组合；让玩家选择这样的2只怪兽，设置为对象，并设置回到手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 取得双方场上所有表侧表示、可回手卡且可作对象的怪兽组
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	if chkc then return false end
	if chk==0 then return g:CheckSubGroup(s.fselect,2,2) end
	-- 提示玩家选择要回到手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local sg=g:SelectSubGroup(tp,s.fselect,false,2,2)
	-- 把选中的2只怪兽设置为当前连锁处理的对象
	Duel.SetTargetCard(sg)
	-- 设置本次连锁的操作信息为「回到手卡」，记录可能成为处理对象的怪兽组及其数量
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- ②效果的处理：取得与本连锁关联的对象卡，若存在则将它们送去持有者的手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得与本连锁处理关联的对象卡组
	local g=Duel.GetTargetsRelateToChain()
	if g:GetCount()>0 then
		-- 以效果原因把那些怪兽送去持有者（参数nil表示各自的持有者）的手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
