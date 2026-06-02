--F・HERO シャイニング・フレア・ウィングマン
-- 效果：
-- 融合怪兽＋场上的表侧表示怪兽
-- 这个卡名在规则上也当作「元素英雄」卡使用。这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡从额外卡组特殊召唤的场合才能发动。从自己墓地让5只怪兽回到卡组。那之后，自己抽2张，这张卡的攻击力上升1000。
-- ②：这张卡战斗破坏怪兽的场合发动。给与对方那只怪兽的原本攻击力数值的伤害。
local s,id,o=GetID()
-- 注册卡片效果：包含苏生限制限制、融合召唤手续设定、①从额外卡组特殊召唤成功时让墓地5只怪兽回到卡组，抽2张且攻击力上升1000的诱发效果，以及②战斗破坏怪兽时给与对方其原本攻击力伤害的诱发必发效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合召唤的素材：融合怪兽＋场上的表侧表示怪兽。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionType,TYPE_FUSION),s.matfilter2,true)
	-- ①：这张卡从额外卡组特殊召唤的场合才能发动。从自己墓地让5只怪兽回到卡组。那之后，自己抽2张，这张卡的攻击力上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"回到卡组"
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏怪兽的场合发动。给与对方那只怪兽的原本攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"给与伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	-- 战斗破坏怪兽效果的发动条件判定：确认此卡在场上且和战斗破坏有关。
	e2:SetCondition(aux.bdcon)
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
end
-- 过滤条件：作为融合素材的、场上正面表侧表示的怪兽。
function s.matfilter2(c)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
end
-- 效果①的发动条件：这张卡是从额外卡组特殊召唤成功的场合。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_EXTRA)
end
-- 过滤条件：自己墓地中可以回到卡组的怪兽。
function s.tdfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 效果①的发动检测与效果分类注册，表明包含将怪兽送回卡组、抽卡以及提升攻击力的效果。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果前，检查自己是否能够由于效果而抽卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2)
		-- 且自己墓地是否存在至少5只满足过滤条件的怪兽。
		and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,5,nil) end
	-- 设置连锁信息：包含将自己墓地的5张卡片送回卡组的效果分类。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,5,tp,LOCATION_GRAVE)
	-- 设置连锁信息：包含抽2张卡的效果分类。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果①的效果处理：从墓地选5只怪兽回到卡组，那之后抽2张卡，并让此卡的攻击力上升1000。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己墓地所有可回到卡组的怪兽卡片组。
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil)
	if g:GetCount()<5 then return end
	-- 提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local dg=g:Select(tp,5,5,nil)
	-- 显示被选择要返回卡组的卡片的动画。
	Duel.HintSelection(dg)
	-- 如果成功将所选的卡送回卡组（或额外卡组）并洗牌。
	if Duel.SendtoDeck(dg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
		and dg:IsExists(Card.IsLocation,5,nil,LOCATION_DECK+LOCATION_EXTRA) then
		-- 中断当前效果，使得后面的抽卡和攻击力上升不与送回卡组同时处理。
		Duel.BreakEffect()
		-- 若成功抽了2张卡。
		if Duel.Draw(tp,2,REASON_EFFECT)>0
			and c:IsRelateToChain()
			and c:IsFaceup() then
			-- 这张卡的攻击力上升1000。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(1000)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
	end
end
-- 效果②的发动检测：确认被战斗破坏的怪兽，并注册给与对方其原本攻击力伤害的操作信息。
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetHandler():GetBattleTarget()
	-- 将战斗破坏的怪兽设定为连锁的对象。
	Duel.SetTargetCard(bc)
	local dam=bc:GetAttack()
	if dam<0 then dam=0 end
	-- 设定受到伤害的对象为对方玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 设定受到伤害的参数为该战斗破坏怪兽的攻击力数值。
	Duel.SetTargetParam(dam)
	if dam>0 then
		-- 设置连锁信息：包含对对方玩家造成指定数值伤害的效果分类。
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
	end
end
-- 效果②的效果处理：给与对方被该卡战斗破坏怪兽的原本攻击力数值的伤害。
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被战斗破坏并设定为对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 从连锁中获取设定好的受到伤害的玩家（对方玩家）。
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		local dam=tc:GetAttack()
		if dam>0 then
			-- 通过效果给与对方被破坏怪兽原本攻击力数值的伤害。
			Duel.Damage(p,dam,REASON_EFFECT)
		end
	end
end
