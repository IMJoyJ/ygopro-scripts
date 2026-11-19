--レアメタル・ヴァルキリー
-- 效果：
-- 「稀有金属女郎」＋「稀有金属战士」
-- 这张卡在给对方直接攻击的伤害计算时攻击力上升1000，上场上的这张卡可以和融合区的「稀有金属骑士」互换（这张卡特殊召唤的回合不可以互换。）
function c75923050.initial_effect(c)
	-- 记录这张卡的卡文上记载了「稀有金属骑士」的卡名。
	aux.AddCodeList(c,1412158)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以「稀有金属女郎」和「稀有金属战士」作为融合素材。
	aux.AddFusionProcCode2(c,92421852,38916461,true,true)
	-- 这张卡在给对方直接攻击的伤害计算时攻击力上升1000
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75923050,0))  --"攻击上升"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c75923050.atkcon)
	e1:SetValue(1000)
	c:RegisterEffect(e1)
	-- 上场上的这张卡可以和融合区的「稀有金属骑士」互换（这张卡特殊召唤的回合不可以互换。）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(75923050,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c75923050.spcon)
	e2:SetTarget(c75923050.sptg)
	e2:SetOperation(c75923050.spop)
	c:RegisterEffect(e2)
end
-- 攻击力上升效果的条件判定：检查当前是否处于伤害步骤或伤害计算时，且这张卡正在攻击且没有攻击对象怪兽（即直接攻击）。
function c75923050.atkcon(e)
	-- 获取当前所处的决斗阶段（用于判定是否处于伤害步骤或伤害计算时）。
	local ph=Duel.GetCurrentPhase()
	if not (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) then return false end
	-- 获取本次战斗中发起攻击的怪兽。
	local a=Duel.GetAttacker()
	-- 获取本次战斗中被攻击的对象怪兽（直接攻击时为nil）。
	local d=Duel.GetAttackTarget()
	return a==e:GetHandler() and d==nil
end
-- 互换效果的发动条件判定：检查这张卡来到场上时的回合数是否不等于当前回合数（即非特殊召唤的当回合）。
function c75923050.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断这张卡移动到当前区域的回合数是否不同于当前回合数。
	return e:GetHandler():GetTurnID()~=Duel.GetTurnCount()
end
-- 过滤函数：判断卡片是否为「稀有金属骑士」、能否被特殊召唤，且在场上这张卡离场后存在可从额外卡组特召该卡的空位。
function c75923050.spfilter(c,e,tp,mc)
	-- 判断该卡是否为「稀有金属骑士」、可以常规特殊召唤，且这张卡离场后从额外卡组特召该卡时存在可用怪兽区。
	return c:IsCode(1412158) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 互换效果的目标处理函数（可行性检测部分）：检查这张卡能否返回额外卡组，且额外卡组存在可特殊召唤的「稀有金属骑士」。
function c75923050.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToExtra()
		-- 且检查自己额外卡组中是否存在至少1只满足互换特殊召唤条件的「稀有金属骑士」。
		and Duel.IsExistingMatchingCard(c75923050.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	-- 设置操作信息：预计将场上的这张卡返回额外卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
	-- 设置操作信息：预计从自己的额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 互换效果的效果处理函数：若这张卡仍表侧表示且与效果有联系，将其送回额外卡组后再把「稀有金属骑士」特殊召唤。
function c75923050.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 从自己额外卡组中获取第一只满足条件的「稀有金属骑士」。
		local tc=Duel.GetFirstMatchingCard(c75923050.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,c)
		-- 若存在可特召的「稀有金属骑士」，则将这张卡以效果送回额外卡组并判断是否成功返回。
		if tc and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
			-- 将选定的「稀有金属骑士」以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
