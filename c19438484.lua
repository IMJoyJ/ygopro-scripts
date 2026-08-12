--黒陽竜イリオス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，把额外卡组3只攻击力3000以上的龙族怪兽给对方观看才能发动（同名卡最多1张）。这张卡特殊召唤。
-- ②：这张卡被送去墓地的场合，以自己场上1只龙族的融合·同调·超量·连接怪兽为对象才能发动（双方不能对应这个发动把效果发动）。这个回合，对方不能把那只怪兽作为效果的对象。
local s,id,o=GetID()
-- 初始化卡片效果的函数，注册了手牌特召的起动效果，以及送去墓地时给场上龙族融合/同调/超量/连接怪兽赋予不成为效果对象抗性的诱发效果。
function s.initial_effect(c)
	-- ①：这张卡在手卡存在的场合，把额外卡组3只攻击力3000以上的龙族怪兽给对方观看才能发动（同名卡最多1张）。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合，以自己场上1只龙族的融合·同调·超量·连接怪兽为对象才能发动（双方不能对应这个发动把效果发动）。这个回合，对方不能把那只怪兽作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"赋予抗性"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
-- 过滤函数，筛选出额外卡组中攻击力大于等于3000且未给对方确认过的龙族怪兽。
function s.cfilter(c)
	return c:IsAttackAbove(3000) and c:IsRace(RACE_DRAGON) and not c:IsPublic()
end
-- 特殊召唤效果的Cost函数，检查额外卡组是否满足至少有3种攻击力3000以上的龙族怪兽，并从中选择3张不同名卡给对方观看，然后将额外卡组洗牌。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在自己额外卡组筛选出所有符合条件的怪兽，形成一个卡片组对象。
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_EXTRA,0,nil)
	if chk==0 then return g:GetClassCount(Card.GetCode)>2 end
	-- 向玩家显示选择提示消息，指示其选择用于给对方确认的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家从过滤后的卡片组中选择3张互不同名的怪兽卡。
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
	-- 将选出的3张怪兽卡展示给对方确认。
	Duel.ConfirmCards(1-tp,sg)
	-- 将玩家的额外卡组重新进行洗牌。
	Duel.ShuffleExtra(tp)
end
-- 特殊召唤效果的发动准备与合法性检查函数，确认主要怪兽区域是否有空位，且这张卡自身是否能被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动前判断玩家场上是否有空闲的主要怪兽区域供该卡特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理的操作信息，表明本效果包含在玩家场上特殊召唤这张卡自身的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的执行处理函数，如果该卡还在发动的链条中，则将其特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡以正面表示特殊召唤到玩家自己的场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，筛选出自己场上表侧表示的龙族融合、同调、超量或连接怪兽。
function s.tgfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
end
-- 赋予抗性效果的发动准备与检查函数，在满足有合法对象的前提下，选择1只符合条件的怪兽作为效果对象，并设置双方均不能连锁该发动的连锁限制。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter(chkc) end
	-- 在发动前判断自己场上是否存在至少1只表侧表示的龙族融合、同调、超量或连接怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示选择提示消息，指示其选择表侧表示的怪兽作为对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择自己场上1只符合筛选条件的怪兽作为当前效果的目标对象。
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 限制连锁，使得双方玩家都不能在当前效果的发动后继续追加发动任何效果。
	Duel.SetChainLimit(aux.FALSE)
end
-- 赋予抗性效果的执行处理函数，获取刚才所选的目标对象，并为其注册“在此回合内不受对方效果选为对象”的抗性效果。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在效果发动时被选择的第一个目标怪兽对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 这个回合，对方不能把那只怪兽作为效果的对象。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,2))  --"「黑阳龙 伊利俄斯」效果适用中"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetRange(LOCATION_MZONE)
		-- 设置抗性限制的值为仅防止来自对方的效果选取为对象。
		e1:SetValue(aux.tgoval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
