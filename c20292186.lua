--アーティファクト－デスサイズ
-- 效果：
-- ①：这张卡可以当作魔法卡使用从手卡到魔法与陷阱区域盖放。
-- ②：魔法与陷阱区域盖放的这张卡在对方回合被破坏送去墓地的场合发动。这张卡特殊召唤。
-- ③：对方回合，这张卡特殊召唤成功的场合发动。这个回合，对方不能从额外卡组把怪兽特殊召唤。
function c20292186.initial_effect(c)
	-- 效果原文内容：①：这张卡可以当作魔法卡使用从手卡到魔法与陷阱区域盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MONSTER_SSET)
	e1:SetValue(TYPE_SPELL)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：魔法与陷阱区域盖放的这张卡在对方回合被破坏送去墓地的场合发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20292186,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c20292186.spcon)
	e2:SetTarget(c20292186.sptg)
	e2:SetOperation(c20292186.spop)
	c:RegisterEffect(e2)
	-- 效果原文内容：③：对方回合，这张卡特殊召唤成功的场合发动。这个回合，对方不能从额外卡组把怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(20292186,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c20292186.dcon)
	e3:SetOperation(c20292186.dop)
	c:RegisterEffect(e3)
end
-- 规则层面操作：判断卡片是否在对方回合被破坏送入墓地且处于魔陷区背面表示状态
function c20292186.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEDOWN)
		and c:IsPreviousControler(tp)
		-- 规则层面操作：判断卡片是否因破坏而送入墓地且当前回合不是持有者回合
		and c:IsReason(REASON_DESTROY) and Duel.GetTurnPlayer()~=tp
end
-- 规则层面操作：设置效果处理时将要特殊召唤的卡片信息
function c20292186.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面操作：设置特殊召唤的卡片为自身，数量为1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 规则层面操作：执行特殊召唤操作，将自身以正面表示方式特殊召唤到场上
function c20292186.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 规则层面操作：将自身以正面表示方式特殊召唤到持有者场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 规则层面操作：判断当前回合是否为非持有者回合
function c20292186.dcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：当前回合不是持有者回合
	return Duel.GetTurnPlayer()~=tp
end
-- 规则层面操作：创建一个影响对方的永续效果，禁止对方从额外卡组特殊召唤怪兽
function c20292186.dop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果原文内容：对方不能从额外卡组把怪兽特殊召唤
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(0,1)
	e1:SetTarget(c20292186.sumlimit)
	-- 规则层面操作：将效果注册给指定玩家
	Duel.RegisterEffect(e1,tp)
end
-- 规则层面操作：限制目标怪兽必须来自额外卡组
function c20292186.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA)
end
