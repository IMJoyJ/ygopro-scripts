--紅蓮の王者
-- 效果：
-- 调整＋调整以外的暗属性怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合才能发动。从卡组把有「红莲魔龙」的卡名记述的1张卡加入手卡。
-- ②：对方把怪兽的效果发动时，把场上的这张卡除外才能发动。从额外卡组把1只「红莲魔龙」当作同调召唤作特殊召唤。这个效果特殊召唤的怪兽的攻击力变成2倍，不会被对方的效果破坏。
local s,id,o=GetID()
-- 初始化函数，注册同调召唤手续、①效果（同调召唤成功时检索记述有「红莲魔龙」的卡）和②效果（对方发动怪兽效果时除外自身从额外卡组特殊召唤「红莲魔龙」）
function s.initial_effect(c)
	-- 建立卡片关联密码列表，记录本卡记述了「红莲魔龙」的卡名
	aux.AddCodeList(c,70902743)
	-- 注册同调召唤手续：调整＋调整以外的暗属性怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsAttribute,ATTRIBUTE_DARK),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合才能发动。从卡组把有「红莲魔龙」的卡名记述的1张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：对方把怪兽的效果发动时，把场上的这张卡除外才能发动。从额外卡组把1只「红莲魔龙」当作同调召唤作特殊召唤。这个效果特殊召唤的怪兽的攻击力变成2倍，不会被对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 判断①效果的发动条件：这张卡同调召唤成功
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤函数：卡组中记述有「红莲魔龙」卡名且能加入手牌的卡
function s.thfilter(c)
	-- 过滤条件：卡片文本中记述有「红莲魔龙」卡名，且可以加入手牌
	return aux.IsCodeListed(c,70902743) and c:IsAbleToHand()
end
-- ①效果的发动准备：检查卡组中是否存在可检索的卡，并设置检索的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足检索条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁的操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：从卡组选择1张记述有「红莲魔龙」卡名的卡加入手牌并给对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断②效果的发动条件：对方发动怪兽效果，且场上的这张卡未被战斗破坏
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		and re:IsActiveType(TYPE_MONSTER)
end
-- ②效果的发动代价：将场上的这张卡除外
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将作为发动代价的自身卡片表侧表示除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 过滤函数：额外卡组中的「红莲魔龙」，且能以同调召唤的形式特殊召唤
function s.spfilter(c,e,tp,sc)
	return c:IsCode(70902743) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		-- 检查在作为代价的自身离场后，额外卡组怪兽特殊召唤所需的怪兽区域空格是否足够
		and Duel.GetLocationCountFromEx(tp,tp,sc,c)>0
end
-- ②效果的发动准备：检查必须作为素材的限制，并确认额外卡组是否存在可特殊召唤的「红莲魔龙」，设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在必须作为同调素材的卡片限制
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		-- 检查额外卡组中是否存在至少1只满足特殊召唤条件的「红莲魔龙」
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	-- 设置连锁的操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果的处理：从额外卡组将1只「红莲魔龙」当作同调召唤特殊召唤，并赋予攻击力翻倍以及不会被对方效果破坏的耐性
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，再次检查是否存在必须作为同调素材的卡片限制，若不满足则不处理
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只满足条件的「红莲魔龙」
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil):GetFirst()
	-- 若成功选出怪兽，则尝试将其以同调召唤的形式表侧表示特殊召唤（分步处理）
	if tc and Duel.SpecialSummonStep(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的攻击力变成2倍
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(tc:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		tc:RegisterEffect(e1)
		-- 不会被对方的效果破坏。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetDescription(aux.Stringid(id,2))  --"「红莲王者」的效果特殊召唤"
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		-- 设置不会被对方卡片效果破坏的过滤函数
		e2:SetValue(aux.indoval)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		tc:RegisterEffect(e2)
		-- 完成特殊召唤的最终处理
		Duel.SpecialSummonComplete()
		tc:CompleteProcedure()
	end
end
