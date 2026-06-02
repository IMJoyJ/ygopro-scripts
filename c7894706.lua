--混沌の三幻魔
-- 效果：
-- 不能通常召唤的10星怪兽×3
-- 「混沌之三幻魔」1回合1次用融合召唤以及以下方法才能特殊召唤。
-- ●把自己场上的上记的卡送去墓地的场合可以从额外卡组特殊召唤。
-- ①：场上的这张卡1回合最多2次不会被效果破坏。
-- ②：自己·对方回合最多3次，以对方场上1只表侧表示怪兽为对象才能发动（同一连锁上最多1次）。那只怪兽的效果直到回合结束时无效。那之后，可以让自己基本分回复那个攻击力一半的数值。
local s,id,o=GetID()
-- 初始化效果：注册融合召唤手续、接触融合召唤手续，以及一回合内特招成功时注册限用次数、特殊召唤条件限制、效果抗性以及怪兽效果无效并回复基本分的效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续：需要不能通常召唤的10星怪兽×3作为素材
	aux.AddFusionProcFunRep(c,s.ffilter,3,true)
	-- 设置接触融合召唤手续：把自己场上的上述素材送去墓地才能从额外卡组特殊召唤
	aux.AddContactFusionProcedure(c,s.fsmfiler(c),LOCATION_MZONE,0,Duel.SendtoGrave,REASON_SPSUMMON)
	-- 「混沌之三幻魔」1回合1次用融合召唤以及以下方法才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(s.condition)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)
	-- ●把自己场上的上记的卡送去墓地的场合可以从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	-- ①：场上的这张卡1回合最多2次不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetCountLimit(2)
	e2:SetValue(s.valcon)
	c:RegisterEffect(e2)
	-- ②：自己·对方回合最多3次，以对方场上1只表侧表示怪兽为对象才能发动（同一连锁上最多1次）。那只怪兽的效果直到回合结束时无效。那之后，可以让自己基本分回复那个攻击力一半的数值。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"效果无效"
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(3)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
-- 接触融合召唤的素材过滤判定函数
function s.fsmfiler(ec)
	return	function(c)
				-- 检查怪兽是否可以作为接触融合的Cost送去墓地，并检查当前回合是否还没有特殊召唤过该卡
				return c:IsAbleToGraveAsCost() and Duel.GetFlagEffect(ec:GetControler(),id)==0
			end
end
-- 融合召唤的素材过滤判定函数：等级10且不能通常召唤的怪兽
function s.ffilter(c)
	return not c:IsSummonableCard() and c:IsLevel(10)
end
-- 特殊召唤条件的限制判定函数
function s.splimit(e,se,sp,st)
	-- 检查是否以融合召唤方式特殊召唤，且本回合该玩家没有进行过该卡片的特殊召唤
	return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION and Duel.GetFlagEffect(sp,id)==0
end
-- 特殊召唤成功时的Condition条件函数：判断是否为自身融合召唤或通过自身规则特殊召唤成功
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) or re:GetHandler()==c
end
-- 特殊召唤成功时的Operation操作处理函数
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 为玩家注册当回合有效的Flag标识效果，用于限制一回合只能特殊召唤一次
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
-- 不会被破坏的效果抗性判定函数：仅在被效果破坏时生效
function s.valcon(e,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0
end
-- 无效怪兽效果并回复基本分的Target目标处理函数
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	-- 若选择的是对方场上的表侧表示效果怪兽
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.NegateMonsterFilter(chkc) end
	-- 检查对方场上是否存在表侧表示的效果怪兽且当前连锁没有发动过此卡的效果
	if chk==0 then return Duel.IsExistingTarget(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,nil)
		and c:GetFlagEffect(id+o)==0
	end
	c:RegisterFlagEffect(id+o,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,0,1)
	-- 提示玩家选择要无效的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 让玩家选择对方场上1只表侧表示的效果怪兽作为对象
	local g=Duel.SelectTarget(tp,aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置无效该怪兽效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 无效怪兽效果并回复基本分的Operation具体操作处理函数
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取选择的怪兽对象
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToChain() and tc:IsCanBeDisabledByEffect(e) then
		-- 使被选中对象的相关连锁效果无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只怪兽的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 手动刷新场上卡片的无效状态
		Duel.AdjustInstantly()
		-- 若无效成功的怪兽攻击力不为0，询问玩家是否回复基本分
		if not tc:IsAttack(0) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否回复基本分？"
			-- 中断当前效果处理，使之后的效果处理视为不同时处理
			Duel.BreakEffect()
			-- 让自己回复该怪兽攻击力一半数值的基本分
			Duel.Recover(tp,math.ceil(tc:GetAttack()/2),REASON_EFFECT)
		end
	end
end
