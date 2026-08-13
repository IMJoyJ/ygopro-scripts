--ホーリーナイツ・オルビタエル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只光属性怪兽为对象才能发动。那只怪兽解放，从卡组选1张「圣夜骑士」魔法·陷阱卡在自己场上盖放。这个效果在对方回合也能发动。
-- ②：这张卡在墓地存在，自己场上的表侧表示的龙族·光属性·7星怪兽回到手卡的场合才能发动。这张卡特殊召唤。
function c44818.initial_effect(c)
	-- ①：以自己场上1只光属性怪兽为对象才能发动。那只怪兽解放，从卡组选1张「圣夜骑士」魔法·陷阱卡在自己场上盖放。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44818,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCategory(CATEGORY_SSET)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,44818)
	e1:SetTarget(c44818.settg)
	e1:SetOperation(c44818.setop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己场上的表侧表示的龙族·光属性·7星怪兽回到手卡的场合才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44818,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,44819)
	e2:SetCondition(c44818.spcon)
	e2:SetTarget(c44818.sptg)
	e2:SetOperation(c44818.spop)
	c:RegisterEffect(e2)
end
-- ①效果选择解放对象时的过滤条件：必须是表侧表示、光属性且可以被效果解放的怪兽。
function c44818.releasefilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsReleasableByEffect()
end
-- 筛选卡组中满足条件的卡：卡名含有「圣夜骑士」字段、属于魔法/陷阱卡，并且当前可以盖放到魔法与陷阱区域。
function c44818.setfilter(c)
	return c:IsSetCard(0x159) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- ①效果的发动条件和取对象处理：确认场上存在可选为对象的表侧光属性可解放怪兽，同时卡组里有可盖放的「圣夜骑士」魔法·陷阱卡；连锁选择对象时仅验证所选卡是否合法。
function c44818.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c44818.releasefilter(chkc) end
	-- 检查自己场上是否存在至少1只满足解放条件的表侧光属性怪兽，以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c44818.releasefilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查卡组中是否存在至少1张可以盖放的「圣夜骑士」魔法·陷阱卡。
		and Duel.IsExistingMatchingCard(c44818.setfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 给发动者显示选择提示，要求其从自己场上选择要解放的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让发动者从自己场上选择1只表侧光属性且可解放的怪兽作为效果对象，并记录为连锁对象。
	local g=Duel.SelectTarget(tp,c44818.releasefilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 登记本次效果将执行解放操作，对象为已选择的怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,1,0,0)
end
-- ①效果处理：取回对象怪兽，若对象仍与效果关联且成功解放，则从卡组选1张「圣夜骑士」魔法·陷阱卡盖放到自己场上。
function c44818.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与效果关联，并实际将其解放；解放成功后才执行后续盖放处理。
	if tc and tc:IsRelateToEffect(e) and Duel.Release(tc,REASON_EFFECT)~=0 then
		-- 给发动者显示选择提示，要求其从卡组选择要盖放的「圣夜骑士」魔法·陷阱卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 让发动者从卡组筛选并选择1张满足条件的「圣夜骑士」魔法·陷阱卡。
		local g=Duel.SelectMatchingCard(tp,c44818.setfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选出的魔法·陷阱卡以里侧表示盖放到自己的魔法与陷阱区域。
			Duel.SSet(tp,g:GetFirst())
		end
	end
end
-- ②效果触发条件的过滤：判断回到手卡的怪兽是否原本在自己场上表侧表示，且为龙族·光属性·7星怪兽，控制者为自己，来源为怪兽区。
function c44818.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(7)
end
-- ②效果的触发条件：当满足上述条件的怪兽从自己场上表侧表示回到手卡时，此效果的发动时机成立。
function c44818.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c44818.cfilter,1,nil,tp)
end
-- ②效果的发动条件与目标：确认自己主要怪兽区有可用空位，且此卡在墓地可以特殊召唤；登记特殊召唤的对象为此卡自身。
function c44818.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己场上有足够的怪兽区空格，用于特殊召唤此卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记本次效果将特殊召唤此卡自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：效果处理时若此卡仍在墓地且与效果关联，则将其特殊召唤到自己场上。
function c44818.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将墓地中的此卡以表侧表示特殊召唤到自己怪兽区。
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
