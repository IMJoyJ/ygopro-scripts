--磁石の戦士マグネット・テルスリオン
-- 效果：
-- 这张卡不能通常召唤。把自己的手卡·场上（表侧表示）·墓地的「磁石战士Σ+」「磁石战士Σ-」各1只除外的场合才能从墓地特殊召唤。
-- ①：1回合1次，对方把效果发动时，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。以地属性怪兽为对象发动的场合，也能作为代替而得到那只怪兽的控制权。
-- ②：对方回合，把这张卡解放才能发动。自己的除外状态的2只「磁石战士Σ」怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：为这张卡注册“不能通常召唤”的特殊召唤限制、墓地特殊召唤规则、①的对方发动效果时破坏/夺控效果、②的对方回合解放自身特招除外磁石战士Σ效果。
function s.initial_effect(c)
	-- 在卡片上登记“磁石战士Σ+”“磁石战士Σ-”的卡名，用于效果中关联/提示这些卡名。
	aux.AddCodeList(c,51826619,87814728)
	c:EnableReviveLimit()
	-- 效果外文本：这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把自己的手卡·场上（表侧表示）·墓地的「磁石战士Σ+」「磁石战士Σ-」各1只除外的场合才能从墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ①：1回合1次，对方把效果发动时，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。以地属性怪兽为对象发动的场合，也能作为代替而得到那只怪兽的控制权。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"破坏效果"
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_CONTROL)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	-- ②：对方回合，把这张卡解放才能发动。自己的除外状态的2只「磁石战士Σ」怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetCondition(s.spcon2)
	e4:SetCost(s.spcost2)
	e4:SetTarget(s.sptg2)
	e4:SetOperation(s.spop2)
	c:RegisterEffect(e4)
end
-- 判断可作为特殊召唤素材的卡：必须是表侧表示、能够除外，且卡名是「磁石战士Σ+」或「磁石战士Σ-」。
function s.spcostfilter(c)
	return c:IsFaceupEx() and c:IsAbleToRemoveAsCost() and c:IsCode(51826619,87814728)
end
-- 特殊召唤素材组检查：该组恰好包含「磁石战士Σ+」「磁石战士Σ-」各1只，并且这组卡离开后自己场上仍有主怪兽区空格。
function s.gcheck(g,tp)
	-- 素材组必须同时包含「磁石战士Σ+」（51826619）和「磁石战士Σ-」（87814728）各1只。
	return aux.gfcheck(g,Card.IsCode,51826619,87814728)
		-- 还要满足：把选中的素材作为特殊召唤手续除外后，自己场上仍有至少1个主怪兽区空格。
		and Duel.GetMZoneCount(tp,g)>0
end
-- 墓地特殊召唤的发动条件：若此卡在墓地，检查自己手牌·表侧场上·墓地是否存在上述各1只素材，且场上有可用空格；调用时可以进入特殊召唤手续。
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取符合条件的素材候选组：检索自己手牌、表侧表示怪兽区、墓地的「磁石战士Σ+」「磁石战士Σ-」，排除这张卡本身。
	local g=Duel.GetMatchingGroup(s.spcostfilter,tp,LOCATION_GRAVE+LOCATION_MZONE+LOCATION_HAND,0,c)
	return g:CheckSubGroup(s.gcheck,2,2,tp)
end
-- 选择要除外的2张素材，保留该组对象；若成功选择则将其存入效果标签，进入特殊召唤处理。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 再次获取候选素材组，供玩家从中选择除外的卡。
	local g=Duel.GetMatchingGroup(s.spcostfilter,tp,LOCATION_GRAVE+LOCATION_MZONE+LOCATION_HAND,0,c)
	-- 向玩家发出选择提示：请选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(tp,s.gcheck,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤处理：从效果标签取出选定的素材并除外，完成这次墓地特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	-- 把选定的2张素材卡以表侧表示除外，作为特殊召唤手续的代价。
	Duel.Remove(sg,POS_FACEUP,REASON_SPSUMMON)
	sg:DeleteGroup()
end
-- ①效果的发动条件：连锁对方发动的效果，即对方（1-tp）把效果发动时才能发动。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- ①效果取对象：选择对方场上1只怪兽；若对象不是表侧地属性怪兽，则登记破坏信息；若是表侧地属性，则在效果处理时询问是否改为获得控制权。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 发动时确认：对方场上有至少1只可以成为对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	e:SetLabel(0)
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		if not tc:IsAttribute(ATTRIBUTE_EARTH) or tc:IsFacedown() then
			-- 设定操作信息：本次连锁将以效果破坏1张卡。
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
		else
			e:SetLabel(1)
		end
	end
end
-- ①效果处理：若对象仍相关且在主怪兽区；当标签为1（对象为表侧地属性）且对象控制权可变更，且玩家选择是时获得控制权，否则将其破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得这个效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsLocation(LOCATION_MZONE) then
		if e:GetLabel()==1 and tc:IsControlerCanBeChanged()
			-- 询问玩家是否以“获得控制权”代替破坏。
			and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否获取控制权？"
			-- 让己方获得该对象怪兽的控制权。
			Duel.GetControl(tc,tp)
		else
			-- 若未选择获得控制权，则破坏该对象怪兽。
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
-- ②效果的发动条件：仅限对方回合（当前回合玩家为对方）才能发动。
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是对方。
	return Duel.GetTurnPlayer()==1-tp
end
-- ②效果的代价：解放这张卡；并检查解放后自己场上至少有2个主怪兽区空格。
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 确认这张卡可以解放，且解放后主怪兽区空格不少于2。
	if chk==0 then return c:IsReleasable() and Duel.GetMZoneCount(tp,c)>1 end
	-- 把这张卡解放作为发动代价。
	Duel.Release(c,REASON_COST)
end
-- 特殊召唤对象过滤：除外区表侧表示的「磁石战士Σ」系列怪兽，且满足特殊召唤条件。
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x6066) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动时：不受「青眼精灵龙」同招限制，且除外区存在至少2只可特殊召唤的「磁石战士Σ」；登记特殊召唤操作信息。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return not Duel.IsPlayerAffectedByEffect(tp,59822133)
			-- 检查除外区是否存在至少2只符合特殊召唤条件的「磁石战士Σ」怪兽。
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,2,nil,e,tp)
	end
	-- 设置操作信息：预计从除外区特殊召唤2只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_REMOVED)
end
-- ②效果处理：若「青眼精灵龙」的限制在效果处理时仍未适用，且主怪兽区≥2，则选择2只除外区的「磁石战士Σ」表侧攻击表示特殊召唤。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果处理时再次确认主怪兽区空格不少于2。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取除外区所有符合条件的「磁石战士Σ」怪兽。
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_REMOVED,0,nil,e,tp)
	if g:GetCount()>=2 then
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,2,2,nil)
		-- 将选中的2只怪兽除外状态特殊召唤到自己的主怪兽区（表侧表示）。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
