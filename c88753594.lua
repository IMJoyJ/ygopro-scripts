--月光舞剣虎姫
-- 效果：
-- 「月光」怪兽×3
-- 这张卡不用融合召唤不能特殊召唤。这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡的攻击力上升双方的墓地·除外状态的兽战士族怪兽数量×200。
-- ②：对方不能把场上的这张卡作为效果的对象。
-- ③：把这个回合没有送去墓地的这张卡从墓地除外，以自己场上1只融合怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升3000。
function c88753594.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤素材为3只「月光」怪兽
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xdf),3,true)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 限制这张卡只能通过融合召唤的方式特殊召唤
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- ①：这张卡的攻击力上升双方的墓地·除外状态的兽战士族怪兽数量×200。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c88753594.atkval)
	c:RegisterEffect(e2)
	-- ②：对方不能把场上的这张卡作为效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	-- 设置不能成为对方卡片效果的对象
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- ③：把这个回合没有送去墓地的这张卡从墓地除外，以自己场上1只融合怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升3000。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(88753594,0))
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,88753594)
	-- 限制该效果在送去墓地的回合不能发动
	e4:SetCondition(aux.exccon)
	-- 发动代价为将墓地的这张卡除外
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(c88753594.atktg)
	e4:SetOperation(c88753594.atkop)
	c:RegisterEffect(e4)
end
-- 过滤双方墓地以及除外状态（表侧表示）的兽战士族怪兽
function c88753594.atkfilter1(c)
	return c:IsRace(RACE_BEASTWARRIOR) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
-- 计算双方墓地及除外状态的兽战士族怪兽数量，并返回其乘以200的数值作为攻击力上升值
function c88753594.atkval(e,c)
	-- 获取双方墓地和除外区中满足条件的兽战士族怪兽数量并乘以200
	return Duel.GetMatchingGroupCount(c88753594.atkfilter1,c:GetControler(),LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,nil)*200
end
-- 过滤自己场上表侧表示的融合怪兽
function c88753594.atkfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION)
end
-- 效果③的靶向处理（Target），确认并选择自己场上1只表侧表示的融合怪兽作为对象
function c88753594.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c88753594.atkfilter2(chkc) end
	-- 检查自己场上是否存在可以作为效果对象的表侧表示融合怪兽
	if chk==0 then return Duel.IsExistingTarget(c88753594.atkfilter2,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的融合怪兽作为效果对象
	Duel.SelectTarget(tp,c88753594.atkfilter2,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果③的具体效果处理（Operation），使作为对象的融合怪兽的攻击力直到回合结束时上升3000
function c88753594.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力直到回合结束时上升3000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(3000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
