--アーティファクト－アイギス
-- 效果：
-- 这张卡可以当作魔法卡使用从手卡到魔法与陷阱卡区域盖放。魔法与陷阱卡区域盖放的这张卡在对方回合被破坏送去墓地时，这张卡特殊召唤。对方回合中这张卡特殊召唤成功的场合，直到回合结束时，自己场上的名字带有「古遗物」的怪兽不会成为对方的卡的效果的对象，不会被对方的卡的效果破坏。
function c85080444.initial_effect(c)
	-- 这张卡可以当作魔法卡使用从手卡到魔法与陷阱卡区域盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MONSTER_SSET)
	e1:SetValue(TYPE_SPELL)
	c:RegisterEffect(e1)
	-- 魔法与陷阱卡区域盖放的这张卡在对方回合被破坏送去墓地时，这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(85080444,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c85080444.spcon)
	e2:SetTarget(c85080444.sptg)
	e2:SetOperation(c85080444.spop)
	c:RegisterEffect(e2)
	-- 对方回合中这张卡特殊召唤成功的场合，直到回合结束时，自己场上的名字带有「古遗物」的怪兽不会成为对方的卡的效果的对象，不会被对方的卡的效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(85080444,1))  --"效果耐性"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c85080444.indcon)
	e3:SetOperation(c85080444.indop)
	c:RegisterEffect(e3)
end
-- 特殊召唤效果的发动条件：此卡在魔陷区以盖放状态被破坏并送去自己墓地，且当前为对方回合
function c85080444.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEDOWN)
		and c:IsPreviousControler(tp)
		-- 判断送去墓地的原因是否为破坏，且当前回合玩家不是自己（即对方回合）
		and c:IsReason(REASON_DESTROY) and Duel.GetTurnPlayer()~=tp
end
-- 特殊召唤效果的发动准备：设置特殊召唤的操作信息
function c85080444.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁信息，表明此效果包含将自身特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的执行：若此卡仍存在于墓地，则将其在自己场上表侧表示特殊召唤
function c85080444.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将此卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果耐性效果的发动条件：当前回合为对方回合
function c85080444.indcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否不是自己（即对方回合）
	return Duel.GetTurnPlayer()~=tp
end
-- 耐性效果的适用对象过滤：自己场上表侧表示的名字带有「古遗物」的怪兽
function c85080444.tg(e,c)
	return c:IsFaceup() and c:IsSetCard(0x97)
end
-- 效果耐性效果的执行：在全局注册两个直到回合结束适用的场地效果，使自己场上的「古遗物」怪兽获得不会被对方效果破坏和不会成为对方效果对象的耐性
function c85080444.indop(e,tp,eg,ep,ev,re,r,rp)
	-- 直到回合结束时，自己场上的名字带有「古遗物」的怪兽不会成为对方的卡的效果的对象，不会被对方的卡的效果破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetTarget(c85080444.tg)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置不会被对方的卡的效果破坏的过滤函数
	e1:SetValue(aux.indoval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不会被对方效果破坏的效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	-- 设置不会成为对方的卡的效果对象的过滤函数
	e2:SetValue(aux.tgoval)
	-- 将不会成为对方效果对象的效果注册给玩家
	Duel.RegisterEffect(e2,tp)
end
