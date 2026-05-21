--空牙団の懐剣 ドナ
-- 效果：
-- 种族不同的怪兽2只
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己场上1只「空牙团」怪兽和对方场上1只怪兽为对象才能发动。那些怪兽破坏。
-- ②：把自己场上1只怪兽解放才能发动。原本卡名和解放的怪兽不同的1只「空牙团」怪兽从自己的手卡·墓地特殊召唤。把连接怪兽解放发动的场合，可以再让另1只特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果：设置连接召唤手续、①效果（起动效果，破坏双方场上怪兽）、②效果（起动效果，解放怪兽特召手卡·墓地「空牙团」怪兽）。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续：需要2只怪兽，且满足s.lcheck过滤条件。
	aux.AddLinkProcedure(c,nil,2,2,s.lcheck)
	-- ①：以自己场上1只「空牙团」怪兽和对方场上1只怪兽为对象才能发动。那些怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"双方怪兽破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- ②：把自己场上1只怪兽解放才能发动。原本卡名和解放的怪兽不同的1只「空牙团」怪兽从自己的手卡·墓地特殊召唤。把连接怪兽解放发动的场合，可以再让另1只特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 连接素材过滤条件：素材怪兽的种族必须互不相同。
function s.lcheck(g,lc)
	return g:GetClassCount(Card.GetLinkRace)==g:GetCount()
end
-- ①效果的自己场上怪兽过滤条件：表侧表示的「空牙团」怪兽。
function s.desfilter(c)
	return c:IsSetCard(0x114) and c:IsFaceup()
end
-- ①效果的发动准备与对象选择：检查自己场上是否有表侧表示的「空牙团」怪兽，以及对方场上是否有怪兽，并进行取对象选择。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在可以作为破坏对象的表侧表示「空牙团」怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在可以作为破坏对象的怪兽。
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1只表侧表示的「空牙团」怪兽作为对象。
	local g1=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为对象。
	local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
	-- 设置连锁信息：操作分类为破坏，对象为选择的2只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- ①效果的处理：破坏作为对象的2只怪兽。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关的对象怪兽。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 破坏这些怪兽。
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
-- ②效果的Cost检查：设置标签以标记Cost检测，并返回是否可行。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 可解放怪兽的过滤条件：解放该怪兽后，手卡或墓地存在原本卡名不同且可特殊召唤的「空牙团」怪兽，且有可用的怪兽区域。
function s.costfilter(c,e,tp)
	-- 检查手卡或墓地是否存在原本卡名与解放怪兽不同的「空牙团」怪兽。
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,c,e,tp)
		-- 检查解放该怪兽后，是否能空出可用的怪兽区域。
		and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤怪兽的过滤条件：原本卡名与解放怪兽不同、属于「空牙团」系列、且可以被特殊召唤。
function s.spfilter(c,tc,e,tp)
	return c:GetOriginalCodeRule()~=tc:GetOriginalCodeRule()
		and c:IsSetCard(0x114)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动准备：检查并执行解放怪兽的Cost，记录解放怪兽的信息，若解放的是连接怪兽则设置参数为2，并设置特殊召唤的连锁信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查场上是否存在满足解放条件的怪兽。
		return Duel.CheckReleaseGroup(tp,s.costfilter,1,nil,e,tp)
	end
	e:SetLabel(0)
	-- 选择1只满足条件的怪兽进行解放。
	local g=Duel.SelectReleaseGroup(tp,s.costfilter,1,1,nil,e,tp)
	-- 解放选择的怪兽。
	Duel.Release(g,REASON_COST)
	e:SetLabelObject(g:GetFirst())
	if g:GetFirst():IsType(TYPE_LINK) then
		-- 将连锁参数设置为2（表示解放了连接怪兽，可以特殊召唤最多2只）。
		Duel.SetTargetParam(2)
	end
	-- 设置连锁信息：操作分类为特殊召唤，数量为1，位置为手卡或墓地。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ②效果的处理：从手卡或墓地特殊召唤1只原本卡名不同的「空牙团」怪兽。若解放的是连接怪兽，可选择再特殊召唤另1只。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若没有可用的怪兽区域，则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	-- 获取连锁参数（判断是否解放了连接怪兽）。
	local num=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡或墓地选择1只原本卡名与解放怪兽不同的「空牙团」怪兽（受王家之谷影响）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,tc,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽特殊召唤，若成功且解放的是连接怪兽。
		if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 and num==2
			-- 且自己场上仍有可用的怪兽区域。
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 且手卡或墓地仍存在满足条件的「空牙团」怪兽。
			and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,tc,e,tp)
			-- 询问玩家是否选择再特殊召唤另1只。
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否再选另1只特殊召唤？"
			-- 中断当前效果，使后续的特殊召唤处理视为不同时处理。
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 再次从手卡或墓地选择1只原本卡名与解放怪兽不同的「空牙团」怪兽。
			local g2=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,tc,e,tp)
			-- 将第二只选择的怪兽特殊召唤。
			Duel.SpecialSummon(g2,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
