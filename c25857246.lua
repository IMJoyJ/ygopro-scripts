--ヴァルキュルスの影霊衣
-- 效果：
-- 「影灵衣」仪式魔法卡降临
-- 这张卡若非以只使用除8星以外的怪兽来作的仪式召唤则不能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：对方怪兽的攻击宣言时，从自己墓地把1张「影灵衣」卡除外，把这张卡从手卡丢弃才能发动。那次攻击无效。那之后，战斗阶段结束。
-- ②：自己主要阶段才能发动。自己的手卡·场上最多2只怪兽解放，自己抽出那个数量。
function c25857246.initial_effect(c)
	c:EnableReviveLimit()
	-- 「影灵衣」仪式魔法卡降临 这张卡若非以只使用除8星以外的怪兽来作的仪式召唤则不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件的判定函数为aux.ritlimit，即此卡只能通过仪式召唤方式特殊召唤，其他特殊召唤方式一律不允许。
	e1:SetValue(aux.ritlimit)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。①：对方怪兽的攻击宣言时，从自己墓地把1张「影灵衣」卡除外，把这张卡从手卡丢弃才能发动。那次攻击无效。那之后，战斗阶段结束。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25857246,0))  --"攻击无效"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,25857246)
	e2:SetCondition(c25857246.atkcon)
	e2:SetCost(c25857246.atkcost)
	e2:SetOperation(c25857246.atkop)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的效果1回合各能使用1次。②：自己主要阶段才能发动。自己的手卡·场上最多2只怪兽解放，自己抽出那个数量。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(25857246,1))  --"抽卡"
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,25857247)
	e3:SetTarget(c25857246.target)
	e3:SetOperation(c25857246.operation)
	c:RegisterEffect(e3)
end
-- 仪式素材过滤函数：素材怪兽不能是8星，以满足“只使用除8星以外的怪兽来作仪式召唤”的限制。
function c25857246.mat_filter(c)
	return not c:IsLevel(8)
end
-- ①效果的触发条件：在攻击宣言时点，判断攻击方是否为对方怪兽（即攻击怪兽的控制者是对方），是才可发动。
function c25857246.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查本次攻击宣言的攻击怪兽的控制者是否为效果发动者的对方（1-tp），确保只有对方怪兽攻击宣言时才满足发动条件。
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 代价过滤函数：选择自己墓地中满足「影灵衣」字段（0xb4）且可以被除外的卡，作为①效果发动时除外的代价。
function c25857246.cfilter(c)
	return c:IsSetCard(0xb4) and c:IsAbleToRemoveAsCost()
end
-- ①效果的发动代价检查与执行：chk==0时检查手牌这张卡能否丢弃，且墓地是否存在符合条件的「影灵衣」卡；实际发动时选择并除外墓地1张「影灵衣」卡，并丢弃手牌中的这张卡。
function c25857246.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable()
		-- 检查自己墓地是否存在至少1张满足cfilter过滤条件的「影灵衣」卡（可除外作为代价），作为代价可行性的一部分。
		and Duel.IsExistingMatchingCard(c25857246.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出选择提示，要求发动者从墓地选择1张要除外的「影灵衣」卡，提示信息为请选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1张满足cfilter条件的「影灵衣」卡作为代价除外的对象（不取对象的效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c25857246.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的墓地「影灵衣」卡以表侧表示除外，作为发动代价（REASON_COST）。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	-- 将效果发动的这张卡从手卡丢弃送入墓地，作为发动代价（丢弃加代价）。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- ①效果处理：先无效对方怪兽的攻击；若无效成功，则中断当前效果链，再跳过对方战斗阶段，使战斗阶段结束。
function c25857246.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 调用Duel.NegateAttack()无效此次攻击，若无效成功返回true则执行后续的结束战斗阶段处理。
	if Duel.NegateAttack() then
		-- 中断当前效果处理，使后续跳过战斗阶段的处理与攻击无效处理视为不同时进行，以正确产生时点。
		Duel.BreakEffect()
		-- 跳过对方玩家的战斗阶段，相当于“战斗阶段结束”（value=1表示跳过结束步骤直接进入战斗阶段结束）。
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	end
end
-- ②效果的发动目标检查：满足发动条件时（chk==0）确认玩家可以抽卡，并且自己场上·手卡存在至少1只可解放的怪兽。
function c25857246.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认自己是否可以抽取1张卡，若不能抽卡则②效果不能发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 同时检查自己场上·手卡是否存在至少1只可解放的怪兽（效果解放），确保能执行解放效果。
		and Duel.CheckReleaseGroupEx(tp,nil,1,REASON_EFFECT,true,nil) end
	-- 设置操作信息，声明此效果包含抽卡（CATEGORY_DRAW），预计抽1张，处理时再确定具体数量。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果处理：再次确认可抽卡后，计算卡组剩余数（最少视为1、最多取2），选择1到2只场上·手卡的怪兽解放，然后抽取与解放数量相同的卡。
function c25857246.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认玩家可以抽卡，若不能抽卡则终止处理，不进行后续解放。
	if not Duel.IsPlayerCanDraw(tp) then return end
	-- 获取自己卡组当前的卡片数量，用于决定解放怪兽数的上限（卡组为0时按1计算，最多不超过2）。
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if ct==0 then ct=1 end
	if ct>2 then ct=2 end
	-- 选择1到ct只自己场上·手卡的、可被效果解放的怪兽（ct为卡组数限制后的数值，1~2），作为效果处理要解放的对象。
	local g=Duel.SelectReleaseGroupEx(tp,nil,1,ct,REASON_EFFECT,true,nil)
	if g:GetCount()>0 then
		-- 手动展示被选为解放对象的怪兽，并标记它们被选为对象（广义），便于玩家确认。
		Duel.HintSelection(g)
		-- 解放所选择的怪兽（效果解放），并记录实际解放的数量到rct，用于后续抽卡张数。
		local rct=Duel.Release(g,REASON_EFFECT)
		-- 根据实际解放的怪兽数量rct抽卡（因②效果抽卡）。
		Duel.Draw(tp,rct,REASON_EFFECT)
	end
end
