--ヴァンパイア・ロード
-- 效果：
-- ①：这张卡给与对方战斗伤害的场合，宣言1个卡的种类（怪兽·魔法·陷阱）发动。对方把宣言的种类的1张卡从自身卡组送去墓地。
-- ②：这张卡被对方的效果破坏送去墓地的场合，下次的自己准备阶段发动。这张卡从墓地特殊召唤。
function c53839837.initial_effect(c)
	-- ②：这张卡被对方的效果破坏送去墓地的场合，下次的自己准备阶段发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetOperation(c53839837.spr)
	c:RegisterEffect(e1)
	-- ②：这张卡从墓地特殊召唤。
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
-- ②效果的前置标记函数：检测到这张卡被对方的效果破坏送去墓地（且破坏前由自己控制）时登记标记；若送去墓地时正值自己的准备阶段，则记录当前回合数，使特殊召唤效果延后到下一个自己准备阶段；否则标记持续到最近的一个自己准备阶段。
function c53839837.spr(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if bit.band(r,0x41)~=0x41 or rp==tp or c:IsPreviousControler(1-tp) then return end
	-- 判断当前是否为这张卡的控制者（即效果持有者）的自己回合的准备阶段。
	if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_STANDBY then
		-- 记录当前回合数，用于防止特殊召唤效果在被送去墓地的当次准备阶段立即发动，从而实现“下次”自己准备阶段发动。
		e:SetLabel(Duel.GetTurnCount())
		c:RegisterFlagEffect(53839837,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,2)
	else
		e:SetLabel(0)
		c:RegisterFlagEffect(53839837,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,1)
	end
end
-- ②效果的特殊召唤发动条件：已登记“被对方效果破坏送墓”标记，且当前是自己回合的准备阶段，且不是被送去墓地时的那个准备阶段。
function c53839837.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 具体条件：记录的被破坏时的回合数与当前回合数不同（不是当次准备阶段），当前回合玩家是这张卡的持有者，且卡片带有被破坏送墓的标记。
	return e:GetLabelObject():GetLabel()~=Duel.GetTurnCount() and tp==Duel.GetTurnPlayer() and c:GetFlagEffect(53839837)>0
end
-- ②效果的发动目标处理：发动时无需要选择的对象，设置特殊召唤操作信息，并清除已登记的“被破坏送墓”标记（防止效果再次发动）。
function c53839837.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 将墓地的这张卡设定为特殊召唤对象并写入连锁操作信息，供效果发动检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	c:ResetFlagEffect(53839837)
end
-- ②效果的实际特殊召唤处理：若这张卡仍与效果关联（未被除外或转移控制权等），则将它从墓地特殊召唤到自己场上。
function c53839837.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤回持有者（tp）的场上；sumtype为0表示无特殊召唤方式限制，nocheck=false/nolimit=false表示需正常检查召唤条件与苏生限制。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ①效果的发动条件：这张卡给对方玩家造成了战斗伤害（ep≠tp，即受到战斗伤害的玩家不是这张卡的控制者）。
function c53839837.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- ①效果的发动时处理：让玩家宣言一个卡片种类（怪兽/魔法/陷阱），将宣言存入效果标签，并设置将对方卡组中1张该种类的卡送去墓地的操作信息。
function c53839837.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向发动玩家显示“请选择一个种类”的提示，用于配合后续的卡片种类宣言。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)  --"请选择一个种类"
	-- 让玩家宣言一个卡片种类（怪兽/魔法/陷阱），返回值0/1/2对应三种类型，存入效果标签供处理时使用。
	local op=Duel.AnnounceType(tp)
	e:SetLabel(op)
	-- 设置本次效果处理的内容：将对方卡组中1张卡送去墓地（处理时才决定具体是哪张，不取对象，目标玩家为1-tp）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_DECK)
end
-- 过滤函数：用于筛选满足指定种类且可以被效果送去墓地的卡。
function c53839837.tgfilter(c,ty)
	return c:IsType(ty) and c:IsAbleToGrave()
end
-- ①效果的实际处理：根据宣言的种类，由对方玩家从自身卡组中选择符合条件的卡（选择出的卡在后续操作中送去墓地）。
function c53839837.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=nil
	-- 向对方玩家显示“请选择要送去墓地的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 当宣言的种类为怪兽（0）时，由对方玩家从自身卡组选择1只怪兽卡。
	if e:GetLabel()==0 then g=Duel.SelectMatchingCard(1-tp,c53839837.tgfilter,1-tp,LOCATION_DECK,0,1,1,nil,TYPE_MONSTER)
	-- 当宣言的种类为魔法（1）时，由对方玩家从自身卡组选择1张魔法卡。
	elseif e:GetLabel()==1 then g=Duel.SelectMatchingCard(1-tp,c53839837.tgfilter,1-tp,LOCATION_DECK,0,1,1,nil,TYPE_SPELL)
	-- 当宣言的种类为陷阱（2）时，由对方玩家从自身卡组选择1张陷阱卡。
	else g=Duel.SelectMatchingCard(1-tp,c53839837.tgfilter,1-tp,LOCATION_DECK,0,1,1,nil,TYPE_TRAP) end
	-- 将选出的卡以效果原因送去墓地。
	Duel.SendtoGrave(g,REASON_EFFECT)
end
