--トリックスター・フォクシーウィッチ
-- 效果：
-- 天使族怪兽2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合才能发动。给与对方为对方场上的卡数量×200伤害。
-- ②：连接召唤的这张卡被战斗·效果破坏的场合才能发动。从额外卡组把1只连接2以下的「淘气仙星」怪兽特殊召唤。那之后，给与对方为对方场上的卡数量×200伤害。
function c86750474.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续：天使族怪兽2只以上
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_FAIRY),2)
	-- ①：这张卡特殊召唤成功的场合才能发动。给与对方为对方场上的卡数量×200伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86750474,1))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,86750474)
	e1:SetTarget(c86750474.damtg)
	e1:SetOperation(c86750474.damop)
	c:RegisterEffect(e1)
	-- ②：连接召唤的这张卡被战斗·效果破坏的场合才能发动。从额外卡组把1只连接2以下的「淘气仙星」怪兽特殊召唤。那之后，给与对方为对方场上的卡数量×200伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(86750474,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,86750475)
	e2:SetCondition(c86750474.damcon)
	e2:SetTarget(c86750474.damtg2)
	e2:SetOperation(c86750474.damop2)
	c:RegisterEffect(e2)
end
-- 效果①的发动准备与靶向函数：检查对方场上是否有卡，并设置伤害操作信息
function c86750474.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查可行性：对方场上必须存在至少1张卡
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>0 end
	-- 设置对方玩家为效果处理的目标玩家
	Duel.SetTargetPlayer(1-tp)
	-- 计算伤害数值：对方场上的卡数量乘以200
	local d=Duel.GetFieldGroupCount(1-tp,LOCATION_ONFIELD,0)*200
	-- 设置操作信息：给与对方玩家指定数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,d)
end
-- 效果①的处理函数：计算对方场上的卡数量并给与对方对应数值的伤害
function c86750474.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标玩家（即对方玩家）
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 重新计算当前对方场上的卡数量乘以200的伤害值
	local d=Duel.GetFieldGroupCount(p,LOCATION_ONFIELD,0)*200
	-- 因效果给与目标玩家计算出的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 效果②的发动条件：连接召唤的这张卡在怪兽区域被战斗或效果破坏
function c86750474.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and c:IsSummonType(SUMMON_TYPE_LINK) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 过滤函数：检索额外卡组中可以特殊召唤的连接2以下的「淘气仙星」怪兽
function c86750474.damfilter(c,e,tp)
	-- 过滤条件：属于「淘气仙星」系列、连接2以下、可以特殊召唤，且额外怪兽区域或连接端有空位
	return c:IsSetCard(0xfb) and c:IsLinkBelow(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果②的发动准备与靶向函数：检查额外卡组是否有符合条件的怪兽，并设置特殊召唤和伤害的操作信息
function c86750474.damtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查可行性：额外卡组是否存在至少1只满足过滤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c86750474.damfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 预估伤害数值：对方场上的卡数量乘以200
	local d=Duel.GetFieldGroupCount(1-tp,LOCATION_ONFIELD,0)*200
	-- 设置操作信息：给与对方玩家预估数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,d)
end
-- 效果②的处理函数：从额外卡组特殊召唤1只「淘气仙星」怪兽，那之后给与对方对应伤害
function c86750474.damop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c86750474.damfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	-- 如果成功选择并以表侧表示特殊召唤该怪兽
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 重新计算当前对方场上的卡数量乘以200的伤害值
		local d=Duel.GetFieldGroupCount(1-tp,LOCATION_ONFIELD,0)*200
		if d>0 then
			-- 中断当前效果，使后续的伤害处理与特殊召唤不视为同时处理（对应“那之后”）
			Duel.BreakEffect()
			-- 因效果给与对方玩家计算出的伤害
			Duel.Damage(1-tp,d,REASON_EFFECT)
		end
	end
end
