--ダイナミスト・スピノス
-- 效果：
-- ←3 【灵摆】 3→
-- ①：这张卡以外的自己场上的「雾动机龙」卡被战斗或者对方的效果破坏的场合，可以作为代替把这张卡破坏。
-- 【怪兽效果】
-- ①：可以把这张卡以外的自己场上1只「雾动机龙」怪兽解放，从以下效果选择1个发动。
-- ●这个回合，这张卡可以直接攻击。
-- ●这个回合，这张卡在同1次的战斗阶段中可以作2次攻击。
function c5067884.initial_effect(c)
	-- 为灵摆怪兽c添加灵摆属性，使其可作为灵摆卡在灵摆区发动/放置。
	aux.EnablePendulumAttribute(c)
	-- ①：这张卡以外的自己场上的「雾动机龙」卡被战斗或者对方的效果破坏的场合，可以作为代替把这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTarget(c5067884.reptg)
	e1:SetValue(c5067884.repval)
	e1:SetOperation(c5067884.repop)
	c:RegisterEffect(e1)
	-- ①：可以把这张卡以外的自己场上1只「雾动机龙」怪兽解放，从以下效果选择1个发动。●这个回合，这张卡可以直接攻击。●这个回合，这张卡在同1次的战斗阶段中可以作2次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c5067884.atkcon)
	e2:SetCost(c5067884.atkcost)
	e2:SetTarget(c5067884.atktg)
	e2:SetOperation(c5067884.atkop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判定被破坏的卡是否为表侧表示、自己场上的「雾动机龙」卡，且被战斗或对方的效果破坏（不包含已被代替破坏的情况）。
function c5067884.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsOnField() and c:IsSetCard(0xd8)
		and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)) and not c:IsReason(REASON_REPLACE)
end
-- 代破发动条件判定：存在满足条件的将被破坏的「雾动机龙」卡，且这张灵摆卡自身可被破坏且未处于预定破坏状态。
function c5067884.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(c5067884.repfilter,1,c,tp)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	-- 询问玩家是否用这张卡代替破坏并发动效果，选择是则返回true。
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- EFFECT_DESTROY_REPLACE的Value函数：对将被破坏的卡逐一判断是否满足代破条件。
function c5067884.repval(e,c)
	return c5067884.repfilter(c,e:GetHandlerPlayer())
end
-- 代破处理操作：将这张灵摆卡破坏，以代替原本的破坏。
function c5067884.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果破坏并附带代替破坏原因，将这张灵摆卡破坏，完成代破。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end
-- 起动效果的发动条件：回合玩家当前可以进入战斗阶段（主要阶段中满足进战阶条件）。
function c5067884.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查回合玩家能否进入战斗阶段，用于限制效果只能在能进战阶时发动。
	return Duel.IsAbleToEnterBP()
end
-- 解放代价：从自己场上选择并解放这张卡以外的1只「雾动机龙」怪兽作为发动代价。
function c5067884.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 代价检查（chk==0）：确认自己场上是否存在除本卡外1张可解放的「雾动机龙」怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,c,0xd8) end
	-- 选择1只可解放的「雾动机龙」怪兽作为解放代价对象。
	local rg=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,c,0xd8)
	-- 将选择的怪兽解放，作为发动效果的COST。
	Duel.Release(rg,REASON_COST)
end
-- 效果发动时：根据本回合是否已适用过直接攻击/多次攻击来决定可选选项，让玩家选择其中一个，并将选择结果存入效果的标签。
function c5067884.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local con1=c:GetFlagEffect(5067884)==0
	local con2=c:GetFlagEffect(5067885)==0
	if chk==0 then return con1 or con2 end
	local op=0
	if con1 and con2 then
		-- 当两个效果都尚未适用时，让玩家从“直接攻击”和“多次攻击”中选择1个。
		op=Duel.SelectOption(tp,aux.Stringid(5067884,1),aux.Stringid(5067884,2))  --"直接攻击/多次攻击"
	elseif con1 then
		-- 当只有直接攻击效果尚未适用时，直接选择“直接攻击”（选项序号为0）。
		op=Duel.SelectOption(tp,aux.Stringid(5067884,1))  --"直接攻击"
	else
		-- 当只有多次攻击效果尚未适用时，选择“多次攻击”并将选项序号+1（使op=1表示多次攻击）。
		op=Duel.SelectOption(tp,aux.Stringid(5067884,2))+1  --"多次攻击"
	end
	e:SetLabel(op)
end
-- 效果处理：根据玩家选择的选项，给这张卡赋予本回合可以直接攻击或可额外攻击1次的效果，并设置对应标志位防止重复选择。
function c5067884.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	if op==0 then
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			c:RegisterFlagEffect(5067884,RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END,0,0)
			-- ●这个回合，这张卡可以直接攻击。
			local e1=Effect.CreateEffect(c)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DIRECT_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e1)
		end
	elseif op==1 then
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			c:RegisterFlagEffect(5067885,RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END,0,0)
			-- ●这个回合，这张卡在同1次的战斗阶段中可以作2次攻击。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_EXTRA_ATTACK)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetValue(1)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e2)
		end
	end
end
