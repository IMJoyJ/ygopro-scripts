--零王の契約書
-- 效果：
-- 这个卡名在规则上也当作「DD」卡使用。这个卡名的①的效果1回合只能使用1次。
-- ①：以「零王的契约书」以外的自己场上1张「DD」卡为对象才能发动。那张卡破坏，从卡组把1只「DD」怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是「DD」怪兽不能特殊召唤。
-- ②：自己准备阶段发动。自己受到1000伤害。
local s,id,o=GetID()
-- 在initial_effect中创建并注册三个效果：e1为允许魔陷发动的空效果；e2为①起动效果；e3为②准备阶段必发伤害效果。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以「零王的契约书」以外的自己场上1张「DD」卡为对象才能发动。那张卡破坏，从卡组把1只「DD」怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是「DD」怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ②：自己准备阶段发动。自己受到1000伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"伤害效果"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.damcon)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
end
-- 定义破坏对象的筛选条件：不是本卡、表侧表示、属于「DD」系列，且破坏后自己场上仍有空余怪兽区。
function s.desfilter(c,tp)
	-- 判断对象卡不是「零王的契约书」、表侧表示、属于「DD」字段，且该卡离开后自己主要怪兽区仍有空格可用。
	return not c:IsCode(id) and c:IsFaceup() and c:IsSetCard(0xaf) and Duel.GetMZoneCount(tp,c)>0
end
-- 定义从卡组特殊召唤的候选怪兽条件：属于「DD」字段、是怪兽卡、且可以被玩家tp用效果e以通常方式特殊召唤（不检查召唤条件与苏生限制）。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xaf) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时的取对象与合法性判定：连锁结算时校验对象是自己的且满足desfilter；发动合法时需场上存在可破坏对象且卡组存在可特殊召唤的「DD」怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and s.desfilter(chkc,tp) end
	-- 效果发动检查时，确认自己场上是否存在满足desfilter的卡可作为对象。
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil,tp)
		-- 同时确认卡组中是否存在满足spfilter的「DD」怪兽可供特殊召唤，两者必须同时满足才能发动。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	-- 向玩家显示“请选择要破坏的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从自己场上选择1张满足desfilter的卡作为对象，并将其登记为连锁对象。
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 登记本次连锁的破坏操作信息，目标为已选对象g，数量为1，供相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 登记本次连锁的特殊召唤操作信息，来源为卡组，数量为1，具体卡牌在处理时选择。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：取对象并将其破坏；破坏成功且怪兽区有空位时从卡组选1只「DD」怪兽表侧表示特殊召唤；随后为发动者施加直到回合结束时只能特殊召唤「DD」怪兽的自肃效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与连锁相关，将其以效果破坏；只有破坏成功且自己主要怪兽区有空位时才继续特殊召唤处理。
	if tc:IsRelateToChain() and Duel.Destroy(tc,REASON_EFFECT)~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 向玩家显示“请选择要特殊召唤的卡”的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1张满足spfilter的「DD」怪兽用于特殊召唤。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选出的怪兽以表侧表示特殊召唤到玩家tp场上，不检查召唤条件与苏生限制。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是「DD」怪兽不能特殊召唤。②：自己准备阶段发动。自己受到1000伤害。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果e1注册到场上，使玩家tp在回合结束前不能特殊召唤非「DD」怪兽。
	Duel.RegisterEffect(e1,tp)
end
-- 定义自肃效果的限制条件：禁止特殊召唤的怪兽必须不是「DD」字段，即仅允许特殊召唤「DD」怪兽。
function s.splimit(e,c)
	return not c:IsSetCard(0xaf)
end
-- 定义②效果的发动条件：当前回合玩家是自己（tp），即自己准备阶段。
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否是这张卡的控制者，是则满足准备阶段发动条件。
	return Duel.GetTurnPlayer()==tp
end
-- ②效果的目标设定：必发效果发动时标记伤害对象为控制者自己、伤害值为1000，并登记伤害操作信息。
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将连锁对象玩家设置为tp（自己），确定伤害承受者。
	Duel.SetTargetPlayer(tp)
	-- 设置连锁对象参数为1000，即要受到的伤害数值。
	Duel.SetTargetParam(1000)
	-- 登记本次操作包含1000点伤害效果，供时点与效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,tp,1000)
end
-- ②效果处理：从连锁信息中取出对象玩家和伤害值，对玩家造成效果伤害。
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的对象玩家和对象参数，即伤害承受者与伤害值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对玩家p造成d点效果伤害，完成②效果。
	Duel.Damage(p,d,REASON_EFFECT)
end
