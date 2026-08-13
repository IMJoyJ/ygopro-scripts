--ライゼオル・マスドライバー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这个回合中，以下效果适用。那之后，可以把这张卡作为自己场上的4阶超量怪兽的超量素材。
-- ●自己场上的「雷火沸动」怪兽的攻击力上升1000。
-- ②：这张卡从场上以外送去墓地的场合，以对方墓地1张卡为对象才能发动。那张卡除外。
local s,id,o=GetID()
-- 初始化函数：为这张卡注册两个效果——e1为①效果的魔法卡发动效果（自由时点，伤害步骤可发动，1回合1次），e2为②效果的诱发选发效果（从场上以外送去墓地时，以对方墓地1张卡为对象除外，1回合1次）。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这个回合中，以下效果适用。那之后，可以把这张卡作为自己场上的4阶超量怪兽的超量素材。●自己场上的「雷火沸动」怪兽的攻击力上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上以外送去墓地的场合，以对方墓地1张卡为对象才能发动。那张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_ACTIVATE_CONDITION+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.rmcon)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end
-- 定义选择可作为超量素材的4阶超量怪兽的过滤条件：表侧表示、4阶、超量怪兽，且对该效果不免疫。
function s.ovfilter(c,e)
	return c:IsFaceup() and c:IsRank(4) and c:IsType(TYPE_XYZ) and not c:IsImmuneToEffect(e)
end
-- 处理①效果：先给己方场上的「雷火沸动」怪兽赋予攻击力上升1000直到结束阶段；然后若此卡仍适用且己方场上有符合条件的4阶超量怪兽，询问玩家是否将此卡作为超量素材，若选择是则从己方场上选择1只4阶超量怪兽，将此卡叠放作为其超量素材。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ①：这个回合中，以下效果适用。那之后，可以把这张卡作为自己场上的4阶超量怪兽的超量素材。●自己场上的「雷火沸动」怪兽的攻击力上升1000。②：这张卡从场上以外送去墓地的场合，以对方墓地1张卡为对象才能发动。那张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atktg)
	e1:SetValue(1000)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将攻击力提升的持续效果e1注册到当前玩家tp的场上，使其在结束阶段前持续生效（影响己方场上的雷火沸动怪兽）。
	Duel.RegisterEffect(e1,tp)
	-- 检查此卡是否仍与①效果相关联（未因处理离开场上或效果被无效），且己方场上存在可成为超量素材的4阶超量怪兽，以此作为是否执行叠放的前提。
	if c:IsRelateToEffect(e) and Duel.IsExistingMatchingCard(s.ovfilter,tp,LOCATION_MZONE,0,1,nil,e)
		and c:IsCanOverlay() and c:IsOnField()
		-- 弹出是否将这张卡作为超量素材的确认选择，仅当玩家选择“是”时才继续叠放处理。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否作为超量素材？"
		-- 中断当前连锁处理，使接下来的叠放操作错开时点，与前面的攻击力上升处理视为不同时处理。
		Duel.BreakEffect()
		-- 向当前玩家发送选择提示消息，提示接下来需要选择效果对象（即要叠加素材的超量怪兽）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 从己方场上选择1只满足ovfilter条件的表侧4阶超量怪兽，作为这张卡叠放的目标。
		local tc=Duel.SelectMatchingCard(tp,s.ovfilter,tp,LOCATION_MZONE,0,1,1,nil,e):GetFirst()
		if tc then
			c:CancelToGrave()
			-- 将这张卡叠放在选中的4阶超量怪兽下方，作为其超量素材。
			Duel.Overlay(tc,Group.FromCards(c))
		end
	end
end
-- 攻击力上升效果的适用对象筛选：只对卡名含有「雷火沸动」（0x1be）的怪兽生效。
function s.atktg(e,c)
	return c:IsSetCard(0x1be)
end
-- ②效果的发动条件判断：这张卡从场上以外（非场上区域）被送去墓地的场合才满足。
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- ②效果发动时的取对象处理：选择对方墓地1张可以除外的卡作为对象，并设置对应的除外操作信息。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToRemove() end
	-- 效果发动合法性检查：确认对方墓地存在至少1张可以被除外且在效果对象选择范围内的卡，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 向当前玩家发送提示消息，提示选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地1张可以除外的卡作为效果对象，并自动登记为该连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置本连锁的操作信息，声明将除外对方墓地1张卡，供相关时点效果（如星尘龙、王家长眠之谷等）进行检测。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
end
-- ②效果处理：取得对象卡，确认其仍与效果关联且不受王家长眠之谷影响后，将其表侧除外。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡是否仍与效果相关联，并追加王家长眠之谷的免疫判定（NecroValleyFilter），若对象不能除外则不处理。
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将该对象卡以表侧表示除外，原因为效果处理。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
