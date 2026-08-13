--エクソシスター・カルペディベル
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：双方不能把自己场上的「救祓少女」怪兽作为从墓地特殊召唤的怪兽的效果的对象。
-- ②：自己把「救祓少女」怪兽超量召唤的场合，宣言1个卡名才能发动。直到回合结束时，原本卡名和宣言的卡相同的卡的效果无效化。
-- ③：自己的「救祓少女」怪兽进行战斗的攻击宣言时，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
function c30802207.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：双方不能把自己场上的「救祓少女」怪兽作为从墓地特殊召唤的怪兽的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c30802207.eftg)
	e1:SetValue(c30802207.efilter)
	c:RegisterEffect(e1)
	-- 这个卡名的②③的效果1回合各能使用1次。②：自己把「救祓少女」怪兽超量召唤的场合，宣言1个卡名才能发动。直到回合结束时，原本卡名和宣言的卡相同的卡的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30802207,0))  --"宣言卡名将其无效"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,30802207)
	e2:SetCondition(c30802207.bancon)
	e2:SetTarget(c30802207.bantg)
	e2:SetOperation(c30802207.banop)
	c:RegisterEffect(e2)
	-- 这个卡名的②③的效果1回合各能使用1次。③：自己的「救祓少女」怪兽进行战斗的攻击宣言时，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(30802207,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,30802208)
	e3:SetCondition(c30802207.descon)
	e3:SetTarget(c30802207.destg)
	e3:SetOperation(c30802207.desop)
	c:RegisterEffect(e3)
end
-- ①效果的保护对象筛选：表侧表示且属于「救祓少女」字段的怪兽（即自己场上的「救祓少女」怪兽）。
function c30802207.eftg(e,c)
	return c:IsFaceup() and c:IsSetCard(0x172)
end
-- 判定某个效果是否为从墓地特殊召唤的怪兽在怪兽区域发动的怪兽效果，只有这类效果不能把「救祓少女」怪兽作为对象。
function c30802207.efilter(e,re,rp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSummonLocation(LOCATION_GRAVE) and re:GetActivateLocation()==LOCATION_MZONE
end
-- ②的触发条件筛选：表侧表示、属「救祓少女」字段、以超量召唤方式由我方特殊召唤的怪兽。
function c30802207.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x172) and c:IsSummonType(SUMMON_TYPE_XYZ) and c:IsSummonPlayer(tp)
end
-- ②的发动条件：本次超量召唤成功的怪兽中存在满足cfilter的「救祓少女」怪兽，即自己把「救祓少女」怪兽超量召唤成功。
function c30802207.bancon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c30802207.cfilter,1,nil,tp)
end
-- ②发动时的处理：宣言1个卡名，将宣言的卡名存入连锁参数，并设置操作信息类别为CATEGORY_ANNOUNCE。
function c30802207.bantg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向当前玩家显示“请宣言一个卡名”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	-- 让当前玩家宣言1个卡名（卡号），作为要无效的原本卡名。
	local ac=Duel.AnnounceCard(tp)
	-- 将宣言的卡名保存为当前连锁的目标参数，供效果处理时获取。
	Duel.SetTargetParam(ac)
	-- 设置操作信息为‘宣言卡名’类别，使其他卡可以检测到本连锁包含宣言类效果。
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
-- ②效果解决：根据宣言的卡名，直到回合结束时生成三个持续效果——无效场上原本卡名相同的卡的效果、无效连锁中该卡发动的效果、无效作为怪兽的陷阱卡，从而实现‘原本卡名和宣言的卡相同的卡的效果无效化’。
function c30802207.banop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出发动时宣言的卡名（目标参数）。
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local c=e:GetHandler()
	-- 直到回合结束时，原本卡名和宣言的卡相同的卡的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e1:SetTarget(c30802207.distg1)
	e1:SetLabel(ac)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将场上原本卡名与宣言相同的卡效果无效化的持续效果注册到当前玩家。
	Duel.RegisterEffect(e1,tp)
	-- 直到回合结束时，原本卡名和宣言的卡相同的卡的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetCondition(c30802207.discon)
	e2:SetOperation(c30802207.disop)
	e2:SetLabel(ac)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册一个持续效果，监听连锁解决，使宣言卡名相同的卡在连锁中发动的效果被无效。
	Duel.RegisterEffect(e2,tp)
	-- 直到回合结束时，原本卡名和宣言的卡相同的卡的效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c30802207.distg2)
	e3:SetLabel(ac)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 注册使原本卡名与宣言相同的陷阱怪兽效果无效化的持续效果。
	Duel.RegisterEffect(e3,tp)
end
-- 判定卡片是否应被无效：魔法·陷阱卡只需原本卡名与宣言相同；怪兽卡则还要求当前或原本为效果怪兽，避免锁定无效果怪兽。
function c30802207.distg1(e,c)
	local ac=e:GetLabel()
	if c:IsType(TYPE_SPELL+TYPE_TRAP) then
		return c:IsOriginalCodeRule(ac)
	else
		return c:IsOriginalCodeRule(ac) and (c:IsType(TYPE_EFFECT) or c:GetOriginalType()&TYPE_EFFECT~=0)
	end
end
-- 判定怪兽区的陷阱怪兽的原本卡名是否与宣言相同。
function c30802207.distg2(e,c)
	local ac=e:GetLabel()
	return c:IsOriginalCodeRule(ac)
end
-- 判定当前连锁中的效果来源卡是否原本卡名与宣言相同。
function c30802207.discon(e,tp,eg,ep,ev,re,r,rp)
	local ac=e:GetLabel()
	return re:GetHandler():IsOriginalCodeRule(ac)
end
-- 当满足条件时，将连锁中该效果无效化。
function c30802207.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 直接使当前处理的连锁（ev）的效果无效。
	Duel.NegateEffect(ev)
end
-- ③的发动条件：我方存在表侧表示的「救祓少女」怪兽进行战斗的攻击宣言。
function c30802207.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 取得我方正在参与战斗的怪兽（即进行攻击宣言的我方怪兽）。
	local tc=Duel.GetBattleMonster(tp)
	return tc and tc:IsSetCard(0x172) and tc:IsFaceup()
end
-- ③的取对象目标筛选：对方场上的魔法·陷阱卡。
function c30802207.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- ③发动时选择对方场上1张魔法·陷阱卡作为对象，并设置破坏卡片的操作信息。
function c30802207.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c30802207.desfilter(chkc) and chkc:IsControler(1-tp) end
	-- 发动合法性检查：确认对方场上有可以作为对象的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(c30802207.desfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 显示‘请选择要破坏的卡’的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家从对方场上选择1张魔法·陷阱卡，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c30802207.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：本连锁将以效果破坏所选择的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ③效果处理：取出对象卡，若仍与效果关联则将其破坏。
function c30802207.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出当前连锁的第一个对象卡（即之前选择的对方魔法·陷阱卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果破坏该对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
