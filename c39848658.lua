--ワイト・マスター
-- 效果：
-- ①：自己的「白骨王」向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- ②：1回合1次，以自己墓地1只「白骨」或「白骨王」为对象才能发动。把1只「白骨」或者有那个卡名记述的怪兽从卡组送去墓地，作为对象的怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是不死族怪兽不能特殊召唤。
local s,id,o=GetID()
-- 注册该卡的全部效果：①永续魔法卡发动自身的效果；②给己方场上的「白骨王」附加贯穿效果；③起动效果，取对象从墓地特召「白骨」/「白骨王」并从卡组送墓对应卡，且发动后限制不死族特召。
function s.initial_effect(c)
	-- 将「白骨」（32274490）和「白骨王」（36021814）登记为这张卡效果文本中记述的卡名，用于后续通过aux.IsCodeOrListed进行关联检索。
	aux.AddCodeList(c,32274490,36021814)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①效果：给己方场上的「白骨王」赋予贯穿效果，使其向守备表示怪兽攻击时给予攻击力超过守备力的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.pietg)
	c:RegisterEffect(e2)
	-- ②效果：1回合1次的起动效果，取自己墓地1只「白骨」或「白骨王」为对象，处理时从卡组把「白骨」或有其卡名记述的怪兽送去墓地，并将对象怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 贯穿效果的适用对象过滤：只对卡名是「白骨王」（36021814）的己方怪兽生效。
function s.pietg(e,c)
	return c:IsCode(36021814)
end
-- 卡组送墓的过滤条件：选「白骨」或卡名记述了「白骨」的怪兽（通过aux.IsCodeOrListed判定），且必须是怪兽卡并可以被送去墓地。
function s.tgfilter(c)
	-- 该行具体判断：候选卡满足“是「白骨」或卡名记述了「白骨」”、“是怪兽类型”、“可以被送去墓地”三个条件。
	return aux.IsCodeOrListed(c,32274490) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 墓地取对象的过滤条件：对象必须是「白骨」（32274490）或「白骨王」（36021814），并且能被当前玩家用这个效果特殊召唤（不检查苏生限制和召唤条件）。
function s.spfilter(c,e,tp)
	return c:IsCode(32274490,36021814) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动合法性判断与取对象：若在连锁选择对象时校验对象是否位于自己墓地且符合特召条件；发动检查时确认卡组有可送墓的卡、自己主怪兽区有空位、墓地有符合条件的对象。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- ②效果发动条件之一：自己卡组存在可以送去墓地的「白骨」或记述了「白骨」的怪兽卡，且自己的主要怪兽区有空位。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- ②效果发动条件之二：自己墓地存在可以作为对象的「白骨」或「白骨王」，且该对象能够被特殊召唤。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 为选择要特殊召唤的墓地对象弹出选择提示：“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的「白骨」或「白骨王」作为效果对象，并自动登记为该连锁的对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本效果预定会将1张卡从卡组送去墓地，用于连锁判定及相关效果互动。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：本效果预定会将所选择的墓地对象卡进行特殊召唤，登记对象与数量。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果的处理：先取回对象，然后从卡组选1张符合条件的卡送去墓地；送墓成功且对象仍与效果相关、是怪兽且不受王家长眠之谷影响时，将对象特殊召唤；随后施加发动后只能特召不死族怪兽的自肃。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出发动时选择的墓地对象卡。
	local tc=Duel.GetFirstTarget()
	-- 为选择要送去墓地的卡弹出选择提示：“请选择要送去墓地的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己卡组选择1张满足卡组送墓过滤条件的卡（「白骨」或记述了「白骨」的怪兽）。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		local gc=g:GetFirst()
		-- 将选择的卡以效果原因送去墓地，并确认送墓操作实际成功且该卡现在确实在墓地。
		if Duel.SendtoGrave(gc,REASON_EFFECT)~=0 and gc:IsLocation(LOCATION_GRAVE)
			-- 继续确认：墓地对象仍与该效果有关联、对象是怪兽类型，且墓地的对象不受「王家长眠之谷」等使其无法特殊召唤的效果影响，才执行特召。
			and tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and aux.NecroValleyFilter()(tc) then
			-- 将墓地的对象怪兽以表侧攻击表示特殊召唤到己方场上（不检查召唤条件，不检查苏生限制）。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- ②效果适用的自肃：发动后直到回合结束，自己不是不死族怪兽不能特殊召唤，以影响玩家的永续效果形式注册给发动玩家。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 把上述“不能特殊召唤非不死族怪兽”的自肃效果注册到当前回合玩家，持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃效果的判断条件：尝试特殊召唤的怪兽不是不死族（RACE_ZOMBIE）时，禁止该特殊召唤。
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_ZOMBIE)
end
