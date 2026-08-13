--黄金郷のコンキスタドール
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡发动后变成通常怪兽（不死族·光·5星·攻500/守1800）在怪兽区域特殊召唤（也当作陷阱卡使用）。自己场上有「黄金卿 黄金国巫妖」存在的场合，可以再把场上1张表侧表示卡破坏。
-- ②：自己·对方的结束阶段，把墓地的这张卡除外才能发动。从卡组把1张「黄金国永生药」魔法·陷阱卡在自己场上盖放。
function c20590515.initial_effect(c)
	-- 对应效果原文：“这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：这张卡发动后变成通常怪兽（不死族·光·5星·攻500/守1800）在怪兽区域特殊召唤（也当作陷阱卡使用）。自己场上有「黄金卿 黄金国巫妖」存在的场合，可以再把场上1张表侧表示卡破坏。”
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20590515,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,20590515)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c20590515.target)
	e1:SetOperation(c20590515.activate)
	c:RegisterEffect(e1)
	-- 对应效果原文：“②：自己·对方的结束阶段，把墓地的这张卡除外才能发动。从卡组把1张「黄金国永生药」魔法·陷阱卡在自己场上盖放。”
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20590515,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c20590515.setcon)
	e2:SetCountLimit(1,20590515)
	e2:SetHintTiming(TIMING_END_PHASE)
	-- 设置效果②的发动代价为把墓地的这张卡除外，aux.bfgcost 实现了从墓地除外自身作为COST。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c20590515.settg)
	e2:SetOperation(c20590515.setop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件判定：确认自己场上怪兽区域有空位且玩家能按指定数据（不死族·光·5星·攻500/守1800，也当作陷阱卡）将此卡特殊召唤；满足条件后效果才可发动。
function c20590515.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查自己的主要怪兽区域是否有可用的空格，用于后续特殊召唤这张卡。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否能够将这张卡作为不死族·光·5星·攻500/守1800的通常怪兽（也当作陷阱卡）以表侧表示特殊召唤到怪兽区域。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,20590515,0,TYPES_NORMAL_TRAP_MONSTER,500,1800,5,RACE_ZOMBIE,ATTRIBUTE_LIGHT) end
	-- 向系统登记本次效果处理将进行特殊召唤，对象为这张卡自身，数量为1，用于后续发动时点检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义过滤条件：卡片为表侧表示且卡号是95440946（「黄金卿 黄金国巫妖」），用于判断场上是否存在该卡。
function c20590515.filter(c)
	return c:IsFaceup() and c:IsCode(95440946)
end
-- 效果①的实际处理：将这张卡变成通常怪兽（不死族·光·5星·攻500/守1800，也当作陷阱卡）并特殊召唤；若特召成功且自己场上有「黄金卿 黄金国巫妖」，同时场上有表侧表示卡，则询问玩家是否选择1张表侧表示卡破坏。
function c20590515.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时再次确认是否仍满足特殊召唤条件，若不满足则终止本次处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,20590515,0,TYPES_NORMAL_TRAP_MONSTER,500,1800,5,RACE_ZOMBIE,ATTRIBUTE_LIGHT) then return end
	c:AddMonsterAttribute(TYPE_NORMAL+TYPE_TRAP)
	-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域（无视召唤条件，返回成功特召的数量）。
	if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0
		-- 检查自己场上是否存在表侧表示的「黄金卿 黄金国巫妖」，用于决定能否追加破坏效果。
		and Duel.IsExistingMatchingCard(c20590515.filter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查双方场上是否存在任意表侧表示的卡，作为追加破坏的候选对象。
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		-- 询问玩家是否选择发动追加的破坏效果，选择“是”才继续执行破坏。
		and Duel.SelectYesNo(tp,aux.Stringid(20590515,2)) then  --"是否选卡破坏？"
		-- 中断当前效果的连锁处理，使追加的破坏效果视为独立处理，避免错过时点。
		Duel.BreakEffect()
		-- 向玩家显示“请选择要破坏的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 从双方场上表侧表示的卡中选择1张作为破坏对象。
		local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		-- 高亮显示被选中的卡，并将其记录为本连锁中被选择为对象的卡。
		Duel.HintSelection(g)
		local tc=g:GetFirst()
		if tc then
			-- 以效果原因破坏被选中的那张卡。
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
-- 定义效果②的检索条件：卡名属于「黄金国永生药」字段（0x2142）的魔法·陷阱卡，且当前可以被盖放。
function c20590515.setfilter(c)
	return c:IsSetCard(0x2142) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 效果②的发动条件判定函数：仅在结束阶段可以发动。
function c20590515.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为结束阶段（涵盖自己回合及对方回合的结束阶段）。
	return Duel.GetCurrentPhase()==PHASE_END
end
-- 效果②的发动目标检查：确认卡组中存在符合条件的「黄金国永生药」魔法·陷阱卡。
function c20590515.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时检查卡组中是否存在可盖放的符合条件的卡，若存在则允许发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c20590515.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果②的实际处理：从卡组选择1张符合条件的「黄金国永生药」魔法·陷阱卡，盖放到自己场上。
function c20590515.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示“请选择要盖放的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组中选择1张满足检索条件的「黄金国永生药」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c20590515.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡以里侧表示盖放到自己的魔法·陷阱区域。
		Duel.SSet(tp,g)
	end
end
