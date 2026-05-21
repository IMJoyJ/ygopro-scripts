--凛天使クイーン・オブ・ローズ
-- 效果：
-- 这张卡可以把1只植物族怪兽解放表侧攻击表示上级召唤。自己的准备阶段时只有1次，场上表侧表示存在的1只攻击力最低的怪兽破坏。
function c96470883.initial_effect(c)
	-- 这张卡可以把1只植物族怪兽解放表侧攻击表示上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96470883,0))  --"用1只植物族怪兽解放召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c96470883.otcon)
	e1:SetOperation(c96470883.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- 自己的准备阶段时只有1次，场上表侧表示存在的1只攻击力最低的怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(96470883,1))  --"攻击力最低的怪兽破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c96470883.descon)
	e2:SetTarget(c96470883.destg)
	e2:SetOperation(c96470883.desop)
	c:RegisterEffect(e2)
end
-- 过滤用于上级召唤解放的植物族怪兽（自己场上的植物族，或对方场上表侧表示的植物族）
function c96470883.otfilter(c,tp)
	return c:IsRace(RACE_PLANT) and (c:IsControler(tp) or c:IsFaceup())
end
-- 检查是否满足用1只植物族怪兽解放进行上级召唤的条件
function c96470883.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上所有可作为解放祭品的植物族怪兽
	local mg=Duel.GetMatchingGroup(c96470883.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 检查自身等级是否在7星以上、所需最少祭品数是否小于等于1，且场上是否存在1个满足条件的祭品
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 执行用1只植物族怪兽解放进行上级召唤的操作
function c96470883.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取场上所有可作为解放祭品的植物族怪兽
	local mg=Duel.GetMatchingGroup(c96470883.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 让玩家选择1只用于上级召唤的植物族怪兽作为祭品
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 解放选中的怪兽作为上级召唤的祭品
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 过滤场上表侧表示的怪兽
function c96470883.filter(c)
	return c:IsFaceup()
end
-- 检查是否满足准备阶段破坏效果的发动条件
function c96470883.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己
	return tp==Duel.GetTurnPlayer()
end
-- 准备阶段破坏效果的发动准备与目标确认
function c96470883.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(c96470883.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		local tg=g:GetMinGroup(Card.GetAttack)
		-- 设置效果处理信息为破坏1只攻击力最低的怪兽
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
	end
end
-- 准备阶段破坏效果的实际处理
function c96470883.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(c96470883.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		local tg=g:GetMinGroup(Card.GetAttack)
		if tg:GetCount()>1 then
			-- 提示玩家选择要破坏的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sg=tg:Select(tp,1,1,nil)
			-- 破坏玩家选择的攻击力最低的怪兽
			Duel.Destroy(sg,REASON_EFFECT)
		-- 若攻击力最低的怪兽只有1只，则直接将其破坏
		else Duel.Destroy(tg,REASON_EFFECT) end
	end
end
