--黄紡鮄デュオニギス
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合才能发动。把自己场上的水属性怪兽数量的卡从对方卡组上面除外。
-- ②：以自己场上1只4星以下的水属性怪兽为对象才能发动。那只怪兽的等级上升那个原本等级数值。
-- ③：把墓地的这张卡除外才能发动。选场上1只水属性怪兽，那个攻击力直到回合结束时上升除外中的怪兽数量×100。
function c79724755.initial_effect(c)
	-- ①：这张卡特殊召唤成功的场合才能发动。把自己场上的水属性怪兽数量的卡从对方卡组上面除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(79724755,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,79724755)
	e1:SetTarget(c79724755.rmtg)
	e1:SetOperation(c79724755.rmop)
	c:RegisterEffect(e1)
	-- ②：以自己场上1只4星以下的水属性怪兽为对象才能发动。那只怪兽的等级上升那个原本等级数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(79724755,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,79724756)
	e2:SetTarget(c79724755.lvtg)
	e2:SetOperation(c79724755.lvop)
	c:RegisterEffect(e2)
	-- ③：把墓地的这张卡除外才能发动。选场上1只水属性怪兽，那个攻击力直到回合结束时上升除外中的怪兽数量×100。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(79724755,2))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,79724757)
	-- 把墓地的这张卡除外作为发动效果的Cost
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c79724755.atktg)
	e3:SetOperation(c79724755.atkop)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上表侧表示的水属性怪兽
function c79724755.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 效果①的Target函数：检查并设置除外对方卡组顶端卡片的操作信息
function c79724755.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上表侧表示的水属性怪兽数量
	local ct=Duel.GetMatchingGroupCount(c79724755.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 获取对方卡组最上方对应数量的卡片组
	local dg=Duel.GetDecktopGroup(1-tp,ct)
	if chk==0 then return ct>0 and ct>0 and dg:FilterCount(Card.IsAbleToRemove,nil)==ct end
	-- 设置当前连锁的操作信息为除外对方卡组顶端的卡片
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,dg,#dg,0,0)
end
-- 效果①的Operation函数：将对方卡组顶端对应数量的卡片除外
function c79724755.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上表侧表示的水属性怪兽数量
	local ct=Duel.GetMatchingGroupCount(c79724755.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 获取对方卡组最上方对应数量的卡片组
	local dg=Duel.GetDecktopGroup(1-tp,ct)
	if #dg>0 then
		-- 使接下来的操作不进行洗卡检测（防止除外卡组顶端卡片时洗卡）
		Duel.DisableShuffleCheck()
		-- 将这些卡片表侧表示除外
		Duel.Remove(dg,POS_FACEUP,REASON_EFFECT)
	end
end
-- 过滤条件：自己场上4星以下的水属性怪兽
function c79724755.lvfilter(c)
	return c:IsLevelBelow(4) and c79724755.cfilter(c)
end
-- 效果②的Target函数：选择自己场上1只4星以下的水属性怪兽作为对象
function c79724755.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c79724755.lvfilter(chkc) end
	-- 检查是否存在可以作为对象的4星以下水属性怪兽
	if chk==0 then return Duel.IsExistingTarget(c79724755.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择1只满足条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c79724755.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果②的Operation函数：使作为对象的怪兽等级上升其原本等级数值
function c79724755.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的等级上升那个原本等级数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(tc:GetOriginalLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 过滤条件：除外状态中表侧表示的怪兽
function c79724755.cfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
-- 效果③的Target函数：检查除外区是否存在怪兽以及场上是否存在水属性怪兽
function c79724755.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查除外区是否有表侧表示的怪兽，且场上是否有表侧表示的水属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c79724755.cfilter2,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil) and Duel.IsExistingMatchingCard(c79724755.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
-- 效果③的Operation函数：选择场上1只水属性怪兽，使其攻击力上升除外中的怪兽数量×100
function c79724755.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 计算除外中表侧表示的怪兽数量
	local ct=Duel.GetMatchingGroupCount(c79724755.cfilter2,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	if ct==0 then return end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择场上1只表侧表示的水属性怪兽
	local g=Duel.SelectMatchingCard(tp,c79724755.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 显式地在场上框选出被选中的怪兽
		Duel.HintSelection(g)
		-- 那个攻击力直到回合结束时上升除外中的怪兽数量×100。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(ct*100)
		tc:RegisterEffect(e1)
	end
end
