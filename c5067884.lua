--ダイナミスト・スピノス
-- 效果：
-- ←3 【灵摆】 3→
-- ①：这张卡以外的自己场上的「雾动机龙」卡被战斗或者对方的效果破坏的场合，可以作为代替把这张卡破坏。
-- 【怪兽效果】
-- ①：可以把这张卡以外的自己场上1只「雾动机龙」怪兽解放，从以下效果选择1个发动。
-- ●这个回合，这张卡可以直接攻击。
-- ●这个回合，这张卡在同1次的战斗阶段中可以作2次攻击。
function c5067884.initial_effect(c)
	-- 为灵摆怪兽添加灵摆怪兽属性，允许其进行灵摆召唤和灵摆卡的发动
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
-- 过滤函数，用于判断满足条件的「雾动机龙」卡是否可以被代替破坏（必须是自己场上正面表示、且被战斗或对方效果破坏）
function c5067884.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsOnField() and c:IsSetCard(0xd8)
		and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)) and not c:IsReason(REASON_REPLACE)
end
-- 判断是否有满足条件的「雾动机龙」卡被破坏，并确认该灵摆怪兽是否可被破坏
function c5067884.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(c5067884.repfilter,1,c,tp)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	-- 询问玩家是否发动此代替破坏效果
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 返回该灵摆怪兽是否满足代替破坏条件
function c5067884.repval(e,c)
	return c5067884.repfilter(c,e:GetHandlerPlayer())
end
-- 执行代替破坏操作，将该灵摆怪兽以效果和代替原因破坏
function c5067884.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果和代替原因破坏该灵摆怪兽
	Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end
-- 判断当前回合是否可以进入战斗阶段
function c5067884.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否可以进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 检查玩家场上是否有满足条件的「雾动机龙」怪兽可解放，并选择其中一张进行解放作为代价
function c5067884.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查玩家场上是否存在至少一张可解放的「雾动机龙」怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,c,0xd8) end
	-- 从玩家场上选择一张满足条件的「雾动机龙」怪兽进行解放
	local rg=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,c,0xd8)
	-- 将选中的怪兽进行解放，作为发动效果的代价
	Duel.Release(rg,REASON_COST)
end
-- 判断是否可以发动攻击效果，并根据已使用的效果选项决定显示哪一项可选效果
function c5067884.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local con1=c:GetFlagEffect(5067884)==0
	local con2=c:GetFlagEffect(5067885)==0
	if chk==0 then return con1 or con2 end
	local op=0
	if con1 and con2 then
		-- 当两个效果都未使用时，让玩家选择直接攻击或多次攻击
		op=Duel.SelectOption(tp,aux.Stringid(5067884,1),aux.Stringid(5067884,2))  --"直接攻击/多次攻击"
	elseif con1 then
		-- 当直接攻击未使用时，让玩家选择直接攻击
		op=Duel.SelectOption(tp,aux.Stringid(5067884,1))  --"直接攻击"
	else
		-- 当多次攻击未使用时，让玩家选择多次攻击
		op=Duel.SelectOption(tp,aux.Stringid(5067884,2))+1  --"多次攻击"
	end
	e:SetLabel(op)
end
-- 根据玩家选择的效果类型，为该怪兽注册相应的攻击效果
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
