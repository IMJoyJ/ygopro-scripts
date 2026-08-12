--零王の契約書
-- 效果：
-- 这个卡名在规则上也当作「DD」卡使用。这个卡名的①的效果1回合只能使用1次。
-- ①：以「零王的契约书」以外的自己场上1张「DD」卡为对象才能发动。那张卡破坏，从卡组把1只「DD」怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是「DD」怪兽不能特殊召唤。
-- ②：自己准备阶段发动。自己受到1000伤害。
local s,id,o=GetID()
-- 注册场地魔法卡的发动效果，使卡能被正常发动
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
-- 过滤函数，用于判断是否可以作为破坏对象的「DD」卡
function s.desfilter(c,tp)
	-- 返回不是零王的契约书且正面表示的DD卡，并且该卡所在区域有怪兽区可用
	return not c:IsCode(id) and c:IsFaceup() and c:IsSetCard(0xaf) and Duel.GetMZoneCount(tp,c)>0
end
-- 过滤函数，用于判断是否可以特殊召唤的DD怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xaf) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的发动目标选择函数，用于选择要破坏的卡和从卡组特殊召唤的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and s.desfilter(chkc,tp) end
	-- 检查是否有满足条件的破坏对象卡
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil,tp)
		-- 检查卡组中是否有满足条件的DD怪兽可以特殊召唤
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择要破坏的目标卡
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 设置操作信息，表示将要破坏目标卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息，表示将要从卡组特殊召唤DD怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行破坏和特殊召唤操作，并设置不能特殊召唤非DD怪兽的效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否有效且满足破坏和召唤条件
	if tc:IsRelateToChain() and Duel.Destroy(tc,REASON_EFFECT)~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择要特殊召唤的DD怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 设置直到回合结束时不能特殊召唤非DD怪兽的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能特殊召唤非DD怪兽的效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制不能特殊召唤的怪兽类型
function s.splimit(e,c)
	return not c:IsSetCard(0xaf)
end
-- 伤害效果的发动条件函数
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家
	return Duel.GetTurnPlayer()==tp
end
-- 设置伤害效果的目标信息
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置伤害效果的目标玩家
	Duel.SetTargetPlayer(tp)
	-- 设置伤害效果的目标伤害值
	Duel.SetTargetParam(1000)
	-- 设置操作信息，表示将要造成伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,tp,1000)
end
-- 伤害效果的处理函数
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标玩家和目标伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
