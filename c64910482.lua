--TG サイバー・マジシャン
-- 效果：
-- 把自己场上表侧表示存在的这张卡作为名字带有「科技属」的同调怪兽的同调素材的场合，可以把手卡的名字带有「科技属」的怪兽作为其他的调整以外的同调素材。场上存在的这张卡被破坏送去墓地的回合的结束阶段时，可以从自己卡组把「科技属 电子化魔术师」以外的1只名字带有「科技属」的怪兽加入手卡。
function c64910482.initial_effect(c)
	-- 把自己场上表侧表示存在的这张卡作为名字带有「科技属」的同调怪兽的同调素材的场合，可以把手卡的名字带有「科技属」的怪兽作为其他的调整以外的同调素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetTarget(c64910482.syntg)
	e1:SetValue(1)
	e1:SetOperation(c64910482.synop)
	c:RegisterEffect(e1)
	-- 场上存在的这张卡被破坏送去墓地
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c64910482.regop)
	c:RegisterEffect(e2)
	-- 可以把手卡的名字带有「科技属」的怪兽作为其他的调整以外的同调素材。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_HAND_SYNCHRO)
	e3:SetTarget(c64910482.hsyntg)
	c:RegisterEffect(e3)
end
-- 过滤场上表侧表示、可以作为该同调怪兽同调素材的怪兽
function c64910482.synfilter1(c,syncard,tuner,f)
	return c:IsFaceupEx() and c:IsCanBeSynchroMaterial(syncard,tuner) and (f==nil or f(c,syncard))
end
-- 过滤手卡中可以作为该同调怪兽同调素材的「科技属」非调整怪兽
function c64910482.synfilter2(c,syncard,tuner,f)
	return c:IsSetCard(0x27) and c:IsNotTuner(syncard) and c:IsCanBeSynchroMaterial(syncard,tuner) and (f==nil or f(c,syncard))
end
-- 递归检查当前选择的卡片组合是否能满足同调召唤的条件
function c64910482.syncheck(c,g,mg,tp,lv,syncard,minc,maxc)
	g:AddCard(c)
	local ct=g:GetCount()
	local res=c64910482.syngoal(g,tp,lv,syncard,minc,ct)
		or (ct<maxc and mg:IsExists(c64910482.syncheck,1,g,g,mg,tp,lv,syncard,minc,maxc))
	g:RemoveCard(c)
	return res
end
-- 检查当前选择的素材数量、等级合计、额外怪兽区域空格以及必须作为素材的限制是否满足同调召唤要求
function c64910482.syngoal(g,tp,lv,syncard,minc,ct)
	return ct>=minc
		and g:CheckWithSumEqual(Card.GetSynchroLevel,lv,ct,ct,syncard)
		-- 检查在这些卡作为素材离场后，额外卡组怪兽出场的可用区域是否大于0
		and Duel.GetLocationCountFromEx(tp,tp,g,syncard)>0
		-- 检查选择的素材中是否包含必须作为同调素材的卡
		and aux.MustMaterialCheck(g,tp,EFFECT_MUST_BE_SMATERIAL)
end
-- 同调召唤素材选择的条件检查，判断是否存在合法的同调素材组合
function c64910482.syntg(e,syncard,f,min,max)
	local minc=min+1
	local maxc=max+1
	local c=e:GetHandler()
	local tp=syncard:GetControler()
	local lv=syncard:GetLevel()
	if lv<=c:GetLevel() then return false end
	local g=Group.FromCards(c)
	-- 获取场上可用的同调素材并过滤出满足条件的卡
	local mg=Duel.GetSynchroMaterial(tp):Filter(c64910482.synfilter1,c,syncard,c,f)
	if syncard:IsSetCard(0x27) then
		-- 获取手卡中满足条件的「科技属」非调整怪兽作为可选素材
		local exg=Duel.GetMatchingGroup(c64910482.synfilter2,tp,LOCATION_HAND,0,c,syncard,c,f)
		mg:Merge(exg)
	end
	return mg:IsExists(c64910482.syncheck,1,g,g,mg,tp,lv,syncard,minc,maxc)
end
-- 执行同调素材的选择操作，并将选中的卡设为同调素材
function c64910482.synop(e,tp,eg,ep,ev,re,r,rp,syncard,f,min,max)
	local minc=min+1
	local maxc=max+1
	local c=e:GetHandler()
	local lv=syncard:GetLevel()
	local g=Group.FromCards(c)
	-- 获取场上可用的同调素材并过滤出满足条件的卡
	local mg=Duel.GetSynchroMaterial(tp):Filter(c64910482.synfilter1,c,syncard,c,f)
	if syncard:IsSetCard(0x27) then
		-- 获取手卡中满足条件的「科技属」非调整怪兽作为可选素材
		local exg=Duel.GetMatchingGroup(c64910482.synfilter2,tp,LOCATION_HAND,0,c,syncard,c,f)
		mg:Merge(exg)
	end
	for i=1,maxc do
		local cg=mg:Filter(c64910482.syncheck,g,g,mg,tp,lv,syncard,minc,maxc)
		if cg:GetCount()==0 then break end
		local minct=1
		if c64910482.syngoal(g,tp,lv,syncard,minc,i) then
			minct=0
		end
		-- 提示玩家选择要作为同调素材的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)  --"请选择要作为同调素材的卡"
		local sg=cg:Select(tp,minct,1,nil)
		if sg:GetCount()==0 then break end
		g:Merge(sg)
	end
	-- 将选定的卡片组设置为本次同调召唤的素材
	Duel.SetSynchroMaterial(g)
end
-- 在场上的这张卡被破坏送去墓地时，注册在结束阶段发动的效果
function c64910482.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_DESTROY) then
		-- 结束阶段时，可以从自己卡组把「科技属 电子化魔术师」以外的1只名字带有「科技属」的怪兽加入手卡。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(64910482,0))  --"检索"
		e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetTarget(c64910482.thtg)
		e1:SetOperation(c64910482.thop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 过滤卡组中「科技属 电子化魔术师」以外的「科技属」怪兽
function c64910482.filter(c)
	return c:IsSetCard(0x27) and not c:IsCode(64910482) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检索效果的发动条件检查与操作信息注册
function c64910482.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「科技属」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c64910482.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果，从卡组选择1只「科技属」怪兽加入手卡并给对方确认
function c64910482.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c64910482.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 限制手卡中可作为同调素材的卡必须是「科技属」非调整怪兽
function c64910482.hsyntg(e,c,syncard)
	return c:IsSetCard(0x27) and c:IsNotTuner(syncard)
end
