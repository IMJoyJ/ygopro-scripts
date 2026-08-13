--ダメージ・トランスレーション
-- 效果：
-- 这个回合自己受到的效果伤害变成一半数值。这个回合的结束阶段时，和受到的效果伤害次数相同数量在自己场上把「幽灵衍生物」（恶魔族·暗·1星·攻/守0）守备表示特殊召唤。
function c35268887.initial_effect(c)
	-- 这个回合自己受到的效果伤害变成一半数值。这个回合的结束阶段时，和受到的效果伤害次数相同数量在自己场上把「幽灵衍生物」（恶魔族·暗·1星·攻/守0）守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c35268887.activate)
	c:RegisterEffect(e1)
	if not c35268887.global_check then
		c35268887.global_check=true
		c35268887[0]=0
		c35268887[1]=0
		-- 受到的效果伤害次数
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DAMAGE)
		ge1:SetOperation(c35268887.checkop)
		-- 将全局伤害计数效果ge1注册到所有玩家，用于在造成伤害事件时记录每位玩家受到效果伤害的次数。
		Duel.RegisterEffect(ge1,0)
		-- 这个回合
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge2:SetOperation(c35268887.clear)
		-- 将阶段切换时的清零效果ge2注册到所有玩家，在每个抽卡阶段开始时把上一回合记录的伤害次数重置为0，保证计数仅对当前回合有效。
		Duel.RegisterEffect(ge2,0)
	end
end
-- 伤害事件触发时的计数函数：若本次伤害原因为效果伤害，则把受到伤害的玩家ep对应的计数加1，累计该玩家本回合受到的效果伤害次数。
function c35268887.checkop(e,tp,eg,ep,ev,re,r,rp)
	if bit.band(r,REASON_EFFECT)~=0 then
		c35268887[ep]=c35268887[ep]+1
	end
end
-- 清零函数：在抽卡阶段开始时将玩家0和玩家1记录的效果伤害次数都重置为0，避免跨回合累计。
function c35268887.clear(e,tp,eg,ep,ev,re,r,rp)
	c35268887[0]=0
	c35268887[1]=0
end
-- 这张卡发动成功后的处理：为发动玩家tp注册伤害改变效果（效果伤害减半），并注册一个在结束阶段触发特殊召唤幽灵衍生物的效果。
function c35268887.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合自己受到的效果伤害变成一半数值。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(c35268887.val)
	e1:SetReset(RESET_PHASE+PHASE_END,1)
	-- 将伤害改变效果e1注册给发动玩家tp，使该玩家在本回合内受到的效果伤害按val函数计算减半。
	Duel.RegisterEffect(e1,tp)
	-- 这个回合的结束阶段时，和受到的效果伤害次数相同数量在自己场上把「幽灵衍生物」（恶魔族·暗·1星·攻/守0）守备表示特殊召唤。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetDescription(aux.Stringid(35268887,0))  --"特殊召唤Token"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetTarget(c35268887.tokentg)
	e2:SetOperation(c35268887.tokenop)
	e2:SetReset(RESET_PHASE+PHASE_END,1)
	-- 将结束阶段特殊召唤衍生物的效果e2注册给发动玩家tp，使其在结束阶段按记录的效果伤害次数召唤对应数量的幽灵衍生物。
	Duel.RegisterEffect(e2,tp)
end
-- 伤害改变数值函数：若即将受到的伤害为效果伤害，则返回伤害值的一半（向下取整），否则返回原伤害值。
function c35268887.val(e,re,dam,r,rp,rc)
	if bit.band(r,REASON_EFFECT)~=0 then
		return math.floor(dam/2)
	else return dam end
end
-- 特殊召唤衍生物效果的发动条件：本回合次数ct大于0，且（ct为1或当前没有青眼精灵龙禁止同时特招2只以上怪兽的限制），同时主要怪兽区域空格足够且玩家能够特殊召唤幽灵衍生物。
function c35268887.tokentg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=c35268887[tp]
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return ct>0 and (ct==1 or not Duel.IsPlayerAffectedByEffect(tp,59822133))
		-- 检查发动玩家tp的主要怪兽区域空格数是否不少于需要召唤的衍生物数量ct，以保证所有衍生物都有区域可召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>=ct
		-- 确认玩家tp能否将卡号35268888的幽灵衍生物（恶魔族·暗·1星·攻/守0）以表侧守备表示特殊召唤到场上。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,35268888,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE) end
	-- 设定本次效果处理包含生成ct个衍生物，供系统或相关卡牌判定‘衍生物’相关互动。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ct,0,0)
	-- 设定本次效果处理包含特殊召唤ct只怪兽，供系统或相关卡牌判定‘特殊召唤’相关互动。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,0,0)
end
-- 特殊召唤衍生物的效果处理函数：只要存在青眼精灵龙限制且需特招2只以上、或区域空格不足、或玩家不能特招幽灵衍生物，则直接终止处理；否则执行召唤。
function c35268887.tokenop(e,tp,eg,ep,ev,re,r,rp)
	local ct=c35268887[tp]
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if (ct>1 and Duel.IsPlayerAffectedByEffect(tp,59822133))
		-- 若主要怪兽区域空格数小于需要召唤的数量ct，则无法全部特殊召唤，直接终止效果处理。
		or Duel.GetLocationCount(tp,LOCATION_MZONE)<ct
		-- 若玩家不能将幽灵衍生物以表侧守备表示特殊召唤，则直接终止效果处理。
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,35268888,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE) then return end
	for i=1,ct do
		-- 创建一只卡号为35268888的幽灵衍生物，控制者为tp。
		local token=Duel.CreateToken(tp,35268888)
		-- 将刚创建的衍生物作为特殊召唤中的一步，由玩家tp以表侧守备表示特殊召唤到自己的主要怪兽区域（不检查召唤条件与苏生限制）。
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
	-- 完成所有衍生物的特殊召唤处理，正式将本次效果特殊召唤的衍生物全部放置到场上。
	Duel.SpecialSummonComplete()
end
