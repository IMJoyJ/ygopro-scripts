--大翼のバフォメット
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。兽族·4星怪兽以及「合成兽融合」各最多1张从卡组加入手卡。这个效果的发动后，直到回合结束时自己不是融合怪兽不能从额外卡组特殊召唤。
-- ②：这张卡成为融合召唤的素材送去墓地的场合，以自己墓地1只幻想魔族怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 将「合成兽融合」加入此卡的关联卡片密码列表中
	aux.AddCodeList(c,63136489)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。兽族·4星怪兽以及「合成兽融合」各最多1张从卡组加入手卡。这个效果的发动后，直到回合结束时自己不是融合怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡成为融合召唤的素材送去墓地的场合，以自己墓地1只幻想魔族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,id+o)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 过滤卡组中满足条件的卡：4星兽族怪兽或卡名为「合成兽融合」且能加入手牌的卡
function s.filter(c)
	return (c:IsLevel(4) and c:IsRace(RACE_BEAST) or c:IsCode(63136489)) and c:IsAbleToHand()
end
-- 效果①（检索）的发动准备与效果分类设置
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检查选取的卡片组合是否满足：4星怪兽最多1张且「合成兽融合」最多1张
function s.check(g)
	return g:FilterCount(Card.IsLevel,nil,4)<2 and g:FilterCount(Card.IsCode,nil,63136489)<2
end
-- 效果①（检索与誓约限制）的效果处理函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有满足过滤条件的卡
	local tg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local g=tg:SelectSubGroup(tp,s.check,false,1,2)
	if g then
		-- 将选取的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
	-- 这个效果的发动后，直到回合结束时自己不是融合怪兽不能从额外卡组特殊召唤。②：这张卡成为融合召唤的素材送去墓地的场合，以自己墓地1只幻想魔族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.limit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册不能从额外卡组特殊召唤融合怪兽以外怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制只能从额外卡组特殊召唤融合怪兽的过滤函数
function s.limit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_FUSION)
end
-- 效果②（墓地特召）的发动条件：作为融合素材送去墓地的场合
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_FUSION and not c:IsReason(REASON_RETURN)
end
-- 过滤墓地中满足条件的卡：幻想魔族怪兽且可以特殊召唤
function s.sfilter(c,e,tp)
	return c:IsRace(RACE_ILLUSION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②（墓地特召）的靶向选择与合法性检查
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.sfilter(chkc,e,tp) end
	-- 判断自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己墓地是否存在可以作为对象的幻想魔族怪兽
		and Duel.IsExistingTarget(s.sfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只幻想魔族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.sfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息：特殊召唤指定的对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②（墓地特召）的效果处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍符合条件，则将其在自己场上表侧表示特殊召唤
	if tc:IsRelateToEffect(e) then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
end
