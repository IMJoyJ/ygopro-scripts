--枯鰈葉リプレース
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在，对方墓地的卡数量比自己墓地的卡多的场合，自己准备阶段才能发动。这张卡特殊召唤。
-- ②：这张卡的攻击力·守备力上升对方墓地的卡数量×200。
function c50599453.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在，对方墓地的卡数量比自己墓地的卡多的场合，自己准备阶段才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,50599453)
	e1:SetCondition(c50599453.spcon)
	e1:SetTarget(c50599453.sptg)
	e1:SetOperation(c50599453.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击力·守备力上升对方墓地的卡数量×200。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c50599453.adval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
end
-- 效果发动条件判断：当前回合玩家为使用者，且己方墓地卡数少于对方墓地卡数
function c50599453.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家为使用者，且己方墓地卡数少于对方墓地卡数
	return tp==Duel.GetTurnPlayer() and Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,0)<Duel.GetFieldGroupCount(tp,0,LOCATION_GRAVE)
end
-- 特殊召唤效果的发动准备阶段，检查是否有足够的怪兽区域并判断卡片是否可以被特殊召唤
function c50599453.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：将此卡加入特殊召唤的处理对象中
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤的操作函数
function c50599453.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将此卡以正面表示形式特殊召唤到己方场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 攻击力和守备力增加效果的计算函数
function c50599453.adval(e,c)
	-- 返回对方墓地卡数乘以200作为增减数值
	return Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_GRAVE)*200
end
