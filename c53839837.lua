--ヴァンパイア・ロード
-- 效果：
-- ①：这张卡给与对方战斗伤害的场合，宣言1个卡的种类（怪兽·魔法·陷阱）发动。对方把宣言的种类的1张卡从自身卡组送去墓地。
-- ②：这张卡被对方的效果破坏送去墓地的场合，下次的自己准备阶段发动。这张卡从墓地特殊召唤。
function c53839837.initial_effect(c)
	-- ②：这张卡被对方的效果破坏送去墓地的场合，下次的自己准备阶段发动。这张卡从墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetOperation(c53839837.spr)
	c:RegisterEffect(e1)
	-- ②：这张卡被对方的效果破坏送去墓地的场合，下次的自己准备阶段发动。这张卡从墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53839837,4))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c53839837.spcon)
	e2:SetTarget(c53839837.sptg)
	e2:SetOperation(c53839837.spop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ①：这张卡给与对方战斗伤害的场合，宣言1个卡的种类（怪兽·魔法·陷阱）发动。对方把宣言的种类的1张卡从自身卡组送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(53839837,0))  --"宣言卡送去墓地"
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetCondition(c53839837.tgcon)
	e3:SetTarget(c53839837.tgtg)
	e3:SetOperation(c53839837.tgop)
	c:RegisterEffect(e3)
end
-- 记录该卡被送去墓地时是否为己方准备阶段，用于判断是否触发效果
function c53839837.spr(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if bit.band(r,0x41)~=0x41 or rp==tp or c:IsPreviousControler(1-tp) then return end
	-- 判断当前是否为己方准备阶段
	if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_STANDBY then
		-- 记录当前回合数，用于判断是否为下个准备阶段
		e:SetLabel(Duel.GetTurnCount())
		c:RegisterFlagEffect(53839837,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,2)
	else
		e:SetLabel(0)
		c:RegisterFlagEffect(53839837,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,1)
	end
end
-- 判断是否满足特殊召唤的条件：不是当前回合、是己方回合、且拥有标记效果
function c53839837.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 不是当前回合、是己方回合、且拥有标记效果
	return e:GetLabelObject():GetLabel()~=Duel.GetTurnCount() and tp==Duel.GetTurnPlayer() and c:GetFlagEffect(53839837)>0
end
-- 设置特殊召唤的效果处理信息
function c53839837.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 设置特殊召唤的效果处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	c:ResetFlagEffect(53839837)
end
-- 执行特殊召唤操作
function c53839837.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将该卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断是否为对方造成的战斗伤害
function c53839837.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 设置宣言卡种类的效果处理信息
function c53839837.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示玩家选择卡的种类
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)  --"请选择一个种类"
	-- 让玩家宣言一个卡的种类
	local op=Duel.AnnounceType(tp)
	e:SetLabel(op)
	-- 设置送去墓地的效果处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_DECK)
end
-- 过滤满足类型和可送去墓地条件的卡
function c53839837.tgfilter(c,ty)
	return c:IsType(ty) and c:IsAbleToGrave()
end
-- 根据宣言的种类选择对应类型的卡并送去墓地
function c53839837.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=nil
	-- 提示对方选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 若宣言为怪兽，则选择怪兽类型卡
	if e:GetLabel()==0 then g=Duel.SelectMatchingCard(1-tp,c53839837.tgfilter,1-tp,LOCATION_DECK,0,1,1,nil,TYPE_MONSTER)
	-- 若宣言为魔法，则选择魔法类型卡
	elseif e:GetLabel()==1 then g=Duel.SelectMatchingCard(1-tp,c53839837.tgfilter,1-tp,LOCATION_DECK,0,1,1,nil,TYPE_SPELL)
	-- 若宣言为陷阱，则选择陷阱类型卡
	else g=Duel.SelectMatchingCard(1-tp,c53839837.tgfilter,1-tp,LOCATION_DECK,0,1,1,nil,TYPE_TRAP) end
	-- 将选中的卡送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
end
