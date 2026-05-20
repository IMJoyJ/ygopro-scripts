--DDエクストラ・サーベイヤー
-- 效果：
-- ←4 【灵摆】 4→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：对方场上的表侧表示的怪兽卡被战斗·效果破坏的场合，以自己场上1只「DDD」怪兽为对象才能发动。自己的灵摆区域2张卡除外，这个回合，作为对象的怪兽在同1次的战斗阶段中可以作2次攻击。
-- 【怪兽效果】
-- 这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：把这张卡从手卡丢弃才能发动。从自己的额外卡组（表侧）把「DD 额外测量员」以外的1只「DD」灵摆怪兽加入手卡。
-- ②：这张卡被除外的场合才能发动。把对方的额外卡组的表侧的灵摆怪兽数量的卡从对方卡组上面除外。那之后，可以让自己场上1只「DD」怪兽的攻击力上升这个效果除外的卡数量×200。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数。
function s.initial_effect(c)
	-- 注册灵摆怪兽的灵摆属性（灵摆召唤、灵摆卡的发动）。
	aux.EnablePendulumAttribute(c)
	-- ①：对方场上的表侧表示的怪兽卡被战斗·效果破坏的场合，以自己场上1只「DDD」怪兽为对象才能发动。自己的灵摆区域2张卡除外，这个回合，作为对象的怪兽在同1次的战斗阶段中可以作2次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"2次攻击"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.dacon)
	e1:SetTarget(s.datg)
	e1:SetOperation(s.daop)
	c:RegisterEffect(e1)
	-- ①：把这张卡从手卡丢弃才能发动。从自己的额外卡组（表侧）把「DD 额外测量员」以外的1只「DD」灵摆怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"灵摆怪兽加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ②：这张卡被除外的场合才能发动。把对方的额外卡组的表侧的灵摆怪兽数量的卡从对方卡组上面除外。那之后，可以让自己场上1只「DD」怪兽的攻击力上升这个效果除外的卡数量×200。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_REMOVE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o*2)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
end
-- 过滤对方场上因战斗或效果被破坏的表侧表示怪兽卡。
function s.sfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(1-tp)
		and bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 灵摆效果①的发动条件：对方场上表侧表示怪兽被破坏，且当前处于可以进行战斗相关操作的时点，并且是自己的回合。
function s.dacon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.sfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
		-- 检查当前是否处于可以进行战斗相关操作的时点，且当前回合玩家是自己。
		and aux.bpcon(e,tp,eg,ep,ev,re,r,rp) and Duel.IsTurnPlayer(tp)
end
-- 过滤自己场上表侧表示、没有“可以作2次攻击”效果的「DDD」怪兽。
function s.dafilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10af) and not c:IsHasEffect(EFFECT_EXTRA_ATTACK)
end
-- 灵摆效果①的发动准备（检查自己灵摆区是否有2张卡可除外，以及场上是否有合法的「DDD」怪兽作为对象）。
function s.datg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.dafilter(chkc) end
	-- 检查自己灵摆区域是否存在至少2张可以除外的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_PZONE,0,2,nil)
		-- 检查自己场上是否存在至少1只可以作为效果对象的「DDD」怪兽。
		and Duel.IsExistingTarget(s.dafilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「DDD」怪兽作为效果对象。
	Duel.SelectTarget(tp,s.dafilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁信息，表示该效果包含将自己灵摆区域的2张卡除外的操作。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,tp,LOCATION_PZONE)
end
-- 灵摆效果①的处理：除外自己灵摆区域的2张卡，并使作为对象的怪兽在同一次战斗阶段中可以作2次攻击。
function s.daop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，如果自己灵摆区域可以除外的卡不足2张，则不处理。
	if not Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_PZONE,0,2,nil) then return end
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择自己灵摆区域的2张卡。
	local rg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_PZONE,0,2,2,nil)
	-- 获取本次效果的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 将选中的2张灵摆卡除外，并确认它们是否成功被除外。
	if rg:GetCount()>0 and Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)~=0 and rg:FilterCount(Card.IsLocation,nil,LOCATION_REMOVED)==2
		and tc:IsRelateToEffect(e) then
		-- 这个回合，作为对象的怪兽在同1次的战斗阶段中可以作2次攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 怪兽效果①的发动代价：将手卡的这张卡丢弃。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将这张卡作为发动代价丢弃去墓地。
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 过滤自己额外卡组（表侧表示）中「DD 额外测量员」以外的「DD」灵摆怪兽。
function s.thfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0xaf) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 怪兽效果①的发动准备（检查额外卡组是否有合法的「DD」灵摆怪兽，并设置连锁信息）。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己额外卡组（表侧表示）是否存在满足条件的「DD」灵摆怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置连锁信息，表示该效果包含从额外卡组将1张卡加入手卡的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- 怪兽效果①的处理：从额外卡组选择1只合法的「DD」灵摆怪兽加入手卡，并给对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家选择额外卡组（表侧表示）中1只满足条件的「DD」灵摆怪兽。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 怪兽效果②的发动准备（计算对方额外卡组表侧灵摆怪兽数量，检查对方卡组上方是否有足够数量的卡可以除外，并设置连锁信息）。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算对方额外卡组中表侧表示的灵摆怪兽数量。
	local ct=Duel.GetMatchingGroupCount(aux.AND(Card.IsFaceup,Card.IsType),tp,0,LOCATION_EXTRA,nil,TYPE_PENDULUM)
	-- 获取对方卡组最上方的对应数量的卡片。
	local tg=Duel.GetDecktopGroup(1-tp,ct)
	if chk==0 then return ct>0
		and tg:FilterCount(Card.IsAbleToRemove,nil)==ct end
	-- 设置连锁信息，表示该效果包含从对方卡组上面除外指定数量卡片的操作。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,ct,1-tp,LOCATION_DECK)
end
-- 过滤自己场上表侧表示的「DD」怪兽。
function s.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xaf)
end
-- 怪兽效果②的处理：将对方卡组最上方对应数量的卡除外，之后可选择自己场上1只「DD」怪兽上升除外数量×200的攻击力。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 计算对方除外区中表侧表示的灵摆怪兽数量（脚本中写为除外区，实际对应对方额外卡组表侧灵摆怪兽数）。
	local ct=Duel.GetMatchingGroupCount(aux.AND(Card.IsFaceup,Card.IsType),tp,0,LOCATION_REMOVED,nil,TYPE_PENDULUM)
	if ct==0 then return end
	-- 获取对方卡组最上方的对应数量的卡片。
	local tg=Duel.GetDecktopGroup(1-tp,ct)
	-- 禁用接下来的洗牌检测，防止在从卡组顶端除外卡片时自动洗牌。
	Duel.DisableShuffleCheck()
	-- 将对方卡组最上方的卡片表侧表示除外，并获取实际除外的卡片数量。
	local atk=Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
	-- 检查是否有卡片被成功除外，且自己场上是否存在表侧表示的「DD」怪兽。
	if atk>0 and Duel.IsExistingMatchingCard(s.atkfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 询问玩家是否发动追加效果（让「DD」怪兽上升攻击力）。
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否让「DD」怪兽上升攻击力？"
		-- 提示玩家选择表侧表示的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 玩家选择自己场上1只表侧表示的「DD」怪兽。
		local sg=Duel.SelectMatchingCard(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
		local sc=sg:GetFirst()
		if sc then
			-- 为被除外的卡片组显示被选为对象的动画效果。
			Duel.HintSelection(tg)
			-- 中断当前效果处理，使后续的攻击力上升处理不与除外同时进行。
			Duel.BreakEffect()
			-- 可以让自己场上1只「DD」怪兽的攻击力上升这个效果除外的卡数量×200。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(atk*200)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			sc:RegisterEffect(e1)
		end
	end
end
