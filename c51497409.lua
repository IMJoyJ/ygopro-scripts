--DDD磐石王ダリウス
-- 效果：
-- 恶魔族3星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除，以自己场上1张「契约书」卡为对象才能发动。那张卡破坏，自己从卡组抽1张。这个效果在对方回合也能发动。
-- ②：这张卡和对方怪兽进行战斗的伤害计算时，把这张卡1个超量素材取除才能发动。这张卡不会被那次战斗破坏，伤害计算后那只对方怪兽破坏，给与对方500伤害。
function c51497409.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加XYZ召唤手续：用2只等级3的恶魔族怪兽作为超量素材进行XYZ召唤。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_FIEND),3,2)
	-- ①：1回合1次，把这张卡1个超量素材取除，以自己场上1张「契约书」卡为对象才能发动。那张卡破坏，自己从卡组抽1张。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51497409,0))  --"破坏并抽卡"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c51497409.cost)
	e1:SetTarget(c51497409.ddtg)
	e1:SetOperation(c51497409.ddop)
	c:RegisterEffect(e1)
	-- ②：这张卡和对方怪兽进行战斗的伤害计算时，把这张卡1个超量素材取除才能发动。这张卡不会被那次战斗破坏，伤害计算后那只对方怪兽破坏，给与对方500伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51497409,1))
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetCondition(c51497409.incon)
	e2:SetCost(c51497409.cost)
	e2:SetOperation(c51497409.inop)
	c:RegisterEffect(e2)
end
-- 发动效果的代价：检查并取除这张卡的1个超量素材（作为发动Cost）。
function c51497409.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数：判断卡片是否为表侧表示且具有「契约书」字段（0xae）。
function c51497409.ddfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xae)
end
-- 效果①的目标选择：在发动时确认自己场上存在1张表侧表示的「契约书」卡可取为对象，且自己可以抽卡；若是指定对象则检查该对象是否满足上述条件。
function c51497409.ddtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c51497409.ddfilter(chkc) end
	-- 效果①的发动条件之一：自己是否可以抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 效果①的发动条件之二：自己场上是否存在1张可以作为对象的表侧表示「契约书」卡。
		and Duel.IsExistingTarget(c51497409.ddfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 给玩家显示“请选择要破坏的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从自己场上选择1张表侧表示的「契约书」卡，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c51497409.ddfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设定操作信息：将选择的对象卡登记为将被破坏的卡，用于后续效果连锁的判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设定操作信息：登记自己将抽1张卡，用于抽卡相关时点的检测。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果①处理：取得对象卡，若对象卡仍与效果关联且破坏成功，则自己抽1张卡。
function c51497409.ddop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的那张对象卡。
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍与效果关联，则将其破坏；破坏成功（返回值>0）时继续后续抽卡。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		-- 自己从卡组抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 效果②的发动条件：这张卡正在与对方控制的怪兽进行伤害计算（存在战斗对象且为对方怪兽）。
function c51497409.incon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsControler(1-tp)
end
-- 效果②处理：给这张卡附加“不会被那次战斗破坏”的效果，并注册伤害计算后破坏对方怪兽并给与伤害的连续效果。
function c51497409.inop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 这张卡不会被那次战斗破坏
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		c:RegisterEffect(e1)
		-- 伤害计算后那只对方怪兽破坏，给与对方500伤害。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_BATTLED)
		e2:SetOperation(c51497409.desop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		c:RegisterEffect(e2)
	end
end
-- 伤害计算后的效果处理：将对方那只战斗怪兽破坏，若破坏成功则给与对方500伤害。
function c51497409.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local dc=c:GetBattleTarget()
	-- 确认对方战斗怪兽仍存在并将其破坏；只有破坏成功才继续给予伤害。
	if dc and Duel.Destroy(dc,REASON_EFFECT)>0 then
		-- 给对方玩家造成500点效果伤害。
		Duel.Damage(1-tp,500,REASON_EFFECT)
	end
end
