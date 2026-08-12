--堕天使ディザイア
-- 效果：
-- 这张卡不能特殊召唤。这张卡可以把1只天使族怪兽解放作上级召唤。1回合1次，自己的主要阶段时可以把这张卡的攻击力下降1000，对方场上存在的1只怪兽送去墓地。
function c55690251.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件为始终不满足，即不能特殊召唤
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 这张卡可以把1只天使族怪兽解放作上级召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(55690251,0))  --"用1只天使族怪兽解放作上级召唤"
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetCondition(c55690251.otcon)
	e2:SetOperation(c55690251.otop)
	e2:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e3)
	-- 1回合1次，自己的主要阶段时可以把这张卡的攻击力下降1000，对方场上存在的1只怪兽送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(55690251,1))  --"对方场上存在的1只怪兽送去墓地"
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetCountLimit(1)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(c55690251.target)
	e4:SetOperation(c55690251.operation)
	c:RegisterEffect(e4)
end
-- 过滤场上的天使族怪兽（自己场上的，或者对方场上表侧表示的）
function c55690251.otfilter(c,tp)
	return c:IsRace(RACE_FAIRY) and (c:IsControler(tp) or c:IsFaceup())
end
-- 判断是否满足用1只天使族怪兽解放作上级召唤的条件
function c55690251.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上所有可以作为解放的天使族怪兽
	local mg=Duel.GetMatchingGroup(c55690251.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 判断自身等级是否在7星以上、所需最少祭品数是否小于等于1，且场上是否存在1只满足条件的天使族怪兽作为祭品
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 执行用1只天使族怪兽解放作上级召唤的操作
function c55690251.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取场上所有可以作为解放的天使族怪兽
	local mg=Duel.GetMatchingGroup(c55690251.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 让玩家选择1只用于上级召唤的天使族怪兽作为祭品
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 将选择的怪兽作为上级召唤的祭品解放
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 效果发动的目标选择与可行性检查
function c55690251.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToGrave() end
	-- 检查自身攻击力是否在1000以上，且对方场上是否存在可以送去墓地的怪兽
	if chk==0 then return c:GetAttack()>=1000 and Duel.IsExistingTarget(Card.IsAbleToGrave,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择对方场上1只可以送去墓地的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToGrave,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置将目标怪兽送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- 效果处理：降低自身1000攻击力，并将目标怪兽送去墓地
function c55690251.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and c:GetAttack()>=1000 then
		-- 把这张卡的攻击力下降1000
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1000)
		c:RegisterEffect(e1)
		if tc and tc:IsRelateToEffect(e) and not c:IsHasEffect(EFFECT_REVERSE_UPDATE) then
			-- 将目标怪兽送去墓地
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
end
