--仮初の幻臉師
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次，③的效果在决斗中只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只恶魔族·幻想魔族·魔法师族怪兽送去墓地。那之后，可以把这张卡的种族变成和这个效果送去墓地的怪兽的原本种族相同。
-- ②：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
-- ③：这张卡在墓地存在的场合，从自己墓地把1张魔法卡除外才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 注册此卡的全部效果：①效果（e1/e2）在召唤·特殊召唤成功时发动，从卡组选1只恶魔族·幻想魔族·魔法师族怪兽送去墓地，之后可选将种族变为该怪兽原本种族；②效果（e3）赋予与此卡战斗的双方怪兽“不会被那次战斗破坏”；③效果（e4）在墓地作为起动效果，除外自己墓地1张魔法卡后将自身特殊召唤。
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只恶魔族·幻想魔族·魔法师族怪兽送去墓地。那之后，可以把这张卡的种族变成和这个效果送去墓地的怪兽的原本种族相同。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(s.indtg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ③：这张卡在墓地存在的场合，从自己墓地把1张魔法卡除外才能发动。这张卡特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,id+EFFECT_COUNT_CODE_DUEL)
	e4:SetCost(s.spcost)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- 效果处理时选择送墓对象的过滤函数：检查卡是否为恶魔族、幻想魔族或魔法师族怪兽，且可以被送去墓地。
function s.tgfilter(c)
	return c:IsRace(RACE_FIEND+RACE_ILLUSION+RACE_SPELLCASTER) and c:IsAbleToGrave()
end
-- ①效果的发动条件与操作信息设置函数：chk==0 时检查卡组是否存在至少1只符合条件的怪兽；满足后设置本次处理将把1张卡从卡组送去墓地的操作信息。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动判定：检查卡组中是否存在至少1只满足 tgfilter 的怪兽，存在则允许发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次连锁的操作信息：将把1张卡从卡组送去墓地（CATEGORY_TOGRAVE），供其他卡效果进行时点及效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组选择1只符合条件的怪兽送去墓地；若送墓成功且该卡在墓地、此卡仍与连锁相关并表侧表示，则询问是否变更种族；若确认且原本种族不同，则中断当前效果处理（Duel.BreakEffect），给此卡附加改变为那只怪兽原本种族的效果，持续到离场/无效等重置。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向当前玩家发送选择提示，提示内容为“请选择要送去墓地的卡”，用于选择卡的界面显示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己卡组选择1张满足 tgfilter 的怪兽（效果处理时选择，是不取对象的选择）。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 将选择的怪兽送去墓地（原因：效果），并确认送墓成功、该卡确实在墓地，且此卡仍与连锁相关且表侧表示，只有满足这些条件才继续后续变种族处理。
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0
		and tc:IsLocation(LOCATION_GRAVE)
		and c:IsRelateToChain() and c:IsFaceup() then
		local race=tc:GetOriginalRace()
		-- 若此卡的当前种族与送墓怪兽的原本种族不同，则询问玩家是否要把此卡的种族改为该原本种族。
		if not c:IsRace(race) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否改变种族？"
			-- 调用 Duel.BreakEffect 中断当前效果处理，使后续附加种族改变效果的处理与送墓效果处理错开时点。
			Duel.BreakEffect()
			-- 那之后，可以把这张卡的种族变成和这个效果送去墓地的怪兽的原本种族相同。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_RACE)
			e1:SetValue(race)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
	end
end
-- ②效果的适用对象判定：返回真时表示该怪兽是此卡本身，或是与此卡进行战斗的对方怪兽；这两只怪兽不会被那次战斗破坏。
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
-- ③效果的代价过滤函数：检查墓地中的卡是否为魔法卡（TYPE_SPELL）且可以被除外作为代价。
function s.costfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
-- ③效果的代价函数：chk==0 时检查自己墓地是否存在可除外的魔法卡；满足时提示玩家选择1张魔法卡，将其表侧除外作为发动代价。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认自己墓地存在至少1张满足 costfilter 的魔法卡，可以作为除外代价。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 向当前玩家发送选择提示，提示内容为“请选择要除外的卡”，用于选择代价卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1张满足 costfilter 的魔法卡作为代价（排除此效果持有者自身）。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 将选择的魔法卡以表侧表示除外，作为此效果的发动代价（REASON_COST）。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ③效果的发动条件与目标设置函数：chk==0 时检查自己主要怪兽区有空位，且墓地的此卡可以被特殊召唤；满足后设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有空余区域（>0），用于判断能否特殊召唤此卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次连锁的操作信息：将此卡自身确定为特殊召唤的对象（CATEGORY_SPECIAL_SUMMON），数量1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ③效果处理：若此卡仍与连锁相关且不受王家长眠之谷等墓场效果无效化影响，则将其表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理条件判定：确认此卡仍与发动时的连锁有联系（未被除外或移动导致关系丢失），并通过王家长眠之谷的过滤（墓地效果未被无效），才允许特殊召唤。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将墓地的此卡以表侧表示特殊召唤到自己场上，完成③效果的特殊召唤处理。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
