--異次元の生還者
-- 效果：
-- 自己场上表侧表示存在的这张卡从游戏中除外的场合，这张卡在结束阶段时特殊召唤到场上。
function c48092532.initial_effect(c)
	-- 自己场上表侧表示存在的这张卡从游戏中除外的场合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_REMOVE)
	e1:SetCondition(c48092532.rmcon)
	e1:SetOperation(c48092532.rmop)
	c:RegisterEffect(e1)
	-- 这张卡在结束阶段时特殊召唤到场上。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48092532,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCondition(c48092532.condition)
	e2:SetTarget(c48092532.target)
	e2:SetOperation(c48092532.operation)
	c:RegisterEffect(e2)
end
-- 判断该卡是否为表侧表示状态、是否从场上被除外、是否为自己的控制权
function c48092532.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
end
-- 为该卡注册一个标记，用于记录其已被除外
function c48092532.rmop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(48092532,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 判断该卡是否拥有标记，以确认其是否满足特殊召唤条件
function c48092532.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(48092532)~=0
end
-- 设置特殊召唤的效果目标，并注册一个标记防止重复发动
function c48092532.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(48092533)==0 end
	-- 设置连锁操作信息为特殊召唤类别
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():RegisterFlagEffect(48092533,RESET_EVENT+0x4760000+RESET_PHASE+PHASE_END,0,1)
end
-- 执行特殊召唤操作，若无法召唤则送入墓地
function c48092532.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 判断场上是否有足够的怪兽区域进行特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then
			-- 将该卡送入墓地作为召唤失败的处理
			Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
			return
		end
		-- 将该卡以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
