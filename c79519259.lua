--ナイトウィング・プリースト
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从自己的手卡·卡组·墓地把1张「爆裂模式」在自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。
-- ②：丢弃1张手卡才能发动。从卡组选有「爆裂模式」的卡名记述的1只怪兽加入手卡或特殊召唤。这个回合，自己不是同调怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册「爆裂模式」卡名记述、同调召唤手续与苏生限制，以及盖放「爆裂模式」的①效果与检索或特召相关怪兽的②效果
function s.initial_effect(c)
	-- 记录此卡文本上记述了「爆裂模式」卡名
	aux.AddCodeList(c,80280737)
	-- 注册同调召唤手续，需要调整1只＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 调整＋调整以外的怪兽1只以上 这个卡名的①②的效果1回合各能使用1次。 ①：这张卡特殊召唤的场合才能发动。从自己的手卡·卡组·墓地把1张「爆裂模式」在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"盖放"
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。 ②：丢弃1张手卡才能发动。从卡组选有「爆裂模式」的卡名记述的1只怪兽加入手卡或特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，检查是否为卡号80280737（「爆裂模式」）且可盖放到魔陷区的卡
function s.setfilter(c)
	return c:IsCode(80280737) and c:IsSSetable()
end
-- 发动条件检查，确认自己魔陷区有空位且手卡·卡组·墓地存在可盖放的「爆裂模式」
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己魔法与陷阱区域是否至少有1个空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己手卡·卡组·墓地是否存在至少1张可盖放的「爆裂模式」
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
end
-- 效果处理，从手卡·卡组·墓地（受王家长眠之谷过滤）选1张「爆裂模式」盖放到自己场上并使其在盖放的回合也能发动
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己魔法与陷阱区域没有可用空位则结束处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示控制者选择要盖放的「爆裂模式」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从自己手卡·卡组·墓地（受王家长眠之谷限制过滤）选择1张「爆裂模式」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的「爆裂模式」盖放到自己魔法与陷阱区域
		Duel.SSet(tp,tc)
		-- 这个效果盖放的卡在盖放的回合也能发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))  --"适用「黑翼的祭司」的效果来发动"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 发动代价处理，检查并丢弃自己1张手卡
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡是否存在至少1张可丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 让控制者选择并丢弃1张手卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数，检查是否为文本记述了「爆裂模式」卡名的怪兽，且能加入手卡或在有空位时可特殊召唤
function s.thfilter(c,e,tp)
	-- 判断卡片是否为记述了「爆裂模式」卡名的怪兽
	if not (aux.IsCodeListed(c,80280737) and c:IsType(TYPE_MONSTER)) then return false end
	-- 获取自己怪兽区域的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 发动条件检查，确认自己卡组存在至少1只符合条件的怪兽
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1只满足加入手卡或特殊召唤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
-- 效果处理，从卡组选1只有「爆裂模式」卡名记述的怪兽加入手卡或特殊召唤，并限制本回合从额外卡组仅能特殊召唤同调怪兽
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示控制者从卡组选择要加入手卡或特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从自己卡组选择1只有「爆裂模式」卡名记述的怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 获取当前自己怪兽区的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tc=g:GetFirst()
	if tc then
		-- 判断选中的怪兽是否加入手卡（可加手且无法特召、无空位或玩家选择加手时执行）
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将选中的怪兽加入自己手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方确认加入手卡的怪兽
			Duel.ConfirmCards(1-tp,tc)
		elseif tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			-- 将选中的怪兽表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个回合，自己不是同调怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 为自己注册持续至回合结束的额外卡组同调特殊召唤限制效果
	Duel.RegisterEffect(e2,tp)
end
-- 限制条件，禁止将同调怪兽以外的怪兽从额外卡组特殊召唤
function s.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
