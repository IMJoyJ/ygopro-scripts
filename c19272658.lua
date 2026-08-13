--エクシーズ弁当
-- 效果：
-- ①：对方场上的怪兽被战斗破坏的场合或者被送去墓地的场合，以自己场上1只超量怪兽为对象才能发动。从对方墓地选1只怪兽在作为对象的怪兽下面重叠作为超量素材。
-- ②：把墓地的这张卡除外，以从额外卡组特殊召唤的场上1只怪兽为对象才能发动。那只怪兽的表示形式变更。
function c19272658.initial_effect(c)
	-- ①：对方场上的怪兽被战斗破坏的场合或者被送去墓地的场合，以自己场上1只超量怪兽为对象才能发动。从对方墓地选1只怪兽在作为对象的怪兽下面重叠作为超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCondition(c19272658.ovcon)
	e1:SetTarget(c19272658.ovtg)
	e1:SetOperation(c19272658.ovop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_TO_GRAVE)
	c:RegisterEffect(e2)
	-- ②：把墓地的这张卡除外，以从额外卡组特殊召唤的场上1只怪兽为对象才能发动。那只怪兽的表示形式变更。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	-- 设置②效果的发动代价：把墓地中的此卡除外（aux.bfgcost为通用代价处理）。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c19272658.postg)
	e3:SetOperation(c19272658.posop)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断怪兽之前由对方控制且位于怪兽区，用于确认触发事件中的怪兽来自对方场上。
function c19272658.cfilter(c,tp)
	return c:IsPreviousControler(1-tp) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 效果①的发动条件：本次触发事件（战斗破坏或送去墓地）中至少存在1只对方场上的怪兽。
function c19272658.ovcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c19272658.cfilter,1,nil,tp)
end
-- 对象选择过滤器：选择自己场上表侧表示的超量怪兽作为对象。
function c19272658.ovfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsFaceup()
end
-- 素材选择过滤器：选择对方墓地中的怪兽，且该怪兽可以叠放作为超量素材。
function c19272658.ovfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanOverlay()
end
-- 效果①的取目标流程：校验指定对象（己方表侧超量怪兽）合法性，并确认己方有超量怪兽可取、对方墓地有怪兽可取。
function c19272658.ovtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c19272658.ovfilter(chkc) end
	-- 检查自己场上是否存在至少1只表侧超量怪兽可作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c19272658.ovfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方墓地是否存在至少1只怪兽卡可作为超量素材。
		and Duel.IsExistingMatchingCard(Card.IsType,tp,0,LOCATION_GRAVE,1,nil,TYPE_MONSTER) end
	-- 向玩家显示选择效果对象的提示信息（HINTMSG_TARGET）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 从自己场上选择1只表侧超量怪兽作为效果对象，并记录为连锁对象。
	Duel.SelectTarget(tp,c19272658.ovfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：本效果会让对方墓地中的1只怪兽离开墓地（作为超量素材），用于后续时点/连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,1-tp,LOCATION_GRAVE)
end
-- 效果①处理：取对象超量怪兽；若其仍与效果关联且不免疫，则从对方墓地选择1只可叠放的怪兽，将其叠放在对象怪兽下方作为超量素材。
function c19272658.ovop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的己方场上超量怪兽对象。
	local tc=Duel.GetFirstTarget()
	-- 取得对方墓地中可作超量素材的怪兽组，并用王家长眠之谷过滤器排除受其影响的卡。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c19272658.ovfilter2),tp,0,LOCATION_GRAVE,nil)
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) and g:GetCount()>0 then
		-- 向玩家显示选择超量素材的提示信息（HINTMSG_XMATERIAL）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选择的怪兽作为超量素材叠放到对象超量怪兽下方（Duel.Overlay）。
		Duel.Overlay(tc,sg)
	end
end
-- 对象选择过滤器：选择场上从额外卡组特殊召唤的、且可以变更表示形式的怪兽。
function c19272658.posfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsCanChangePosition()
end
-- 效果②的取目标流程：校验并选择场上1只从额外卡组特殊召唤的可变更表示形式的怪兽作为对象，并设置操作信息为变更表示形式。
function c19272658.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c19272658.posfilter(chkc) end
	-- 检查双方场上是否存在至少1只从额外卡组特殊召唤且可变更表示形式的怪兽作为对象。
	if chk==0 then return Duel.IsExistingTarget(c19272658.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择要改变表示形式的怪兽的提示信息（HINTMSG_POSCHANGE）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 从双方场上选择1只符合条件的怪兽作为效果对象，并记录为连锁对象。
	local g=Duel.SelectTarget(tp,c19272658.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本效果将变更对象怪兽的表示形式（CATEGORY_POSITION）。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果②处理：取得对象怪兽，若仍与效果关联，则将其表示形式进行变更。
function c19272658.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的怪兽对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 变更对象怪兽的表示形式：表侧攻击表示改为表侧守备表示，表侧守备表示改为表侧攻击表示（里侧表示也按对应规则变更）。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
