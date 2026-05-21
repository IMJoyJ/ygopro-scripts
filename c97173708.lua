--トークン生誕祭
-- 效果：
-- 把自己场上的相同等级的衍生物2只以上解放才能发动。从自己墓地选择最多有解放的衍生物数量的和为这张卡发动而解放的衍生物相同等级的怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段时破坏。
function c97173708.initial_effect(c)
	-- 把自己场上的相同等级的衍生物2只以上解放才能发动。从自己墓地选择最多有解放的衍生物数量的和为这张卡发动而解放的衍生物相同等级的怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段时破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetLabel(0)
	e1:SetCost(c97173708.cost)
	e1:SetTarget(c97173708.target)
	e1:SetOperation(c97173708.activate)
	c:RegisterEffect(e1)
end
-- 设置发动代价标记，用于在target函数中识别是否正常通过发动宣言进入
function c97173708.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 过滤条件：场上等级大于0的衍生物，且存在至少1只与其等级相同的其他衍生物可被解放，且墓地存在至少1只相同等级的可特殊召唤的怪兽
function c97173708.rfilter1(c,e,tp)
	local lv=c:GetLevel()
	-- 检查该卡是否为等级大于0的衍生物，且场上是否存在至少1只与其等级相同的其他可解放衍生物
	return lv>0 and c:IsType(TYPE_TOKEN) and Duel.CheckReleaseGroup(tp,c97173708.rfilter2,1,c,lv)
		-- 检查自己墓地是否存在至少1只与该衍生物等级相同且可以特殊召唤的怪兽
		and Duel.IsExistingTarget(c97173708.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,lv)
end
-- 过滤条件：与第一只选定的衍生物等级相同的衍生物
function c97173708.rfilter2(c,clv)
	return c:IsLevel(clv) and c:IsType(TYPE_TOKEN)
end
-- 过滤条件：与解放的衍生物等级相同且可以特殊召唤的怪兽
function c97173708.spfilter(c,e,tp,clv)
	return c:IsLevel(clv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择与处理函数（包括检查是否满足发动条件、选择并解放衍生物、选择墓地的特殊召唤对象）
function c97173708.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c97173708.spfilter(chkc,e,tp,e:GetLabel()) end
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查怪兽区域空位（因为至少要解放2只怪兽，所以即使怪兽区满了，解放后也会空出位置，这里判断空位数大于-2即可）
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>-2
			-- 检查场上是否存在满足解放条件的衍生物
			and Duel.CheckReleaseGroup(tp,c97173708.rfilter1,1,nil,e,tp)
	end
	-- 玩家选择第1只用于解放的衍生物
	local rg1=Duel.SelectReleaseGroup(tp,c97173708.rfilter1,1,1,nil,e,tp)
	local lv=rg1:GetFirst():GetLevel()
	e:SetLabel(lv)
	-- 玩家选择1张以上（最多9张）与第1只衍生物等级相同的其他衍生物
	local rg2=Duel.SelectReleaseGroup(tp,c97173708.rfilter2,1,9,rg1:GetFirst(),lv)
	rg1:Merge(rg2)
	-- 将选定的衍生物全部解放作为发动的代价
	Duel.Release(rg1,REASON_COST)
	-- 获取当前自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>rg1:GetCount() then ft=rg1:GetCount() end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 给玩家发送“请选择要特殊召唤的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地最多有解放的衍生物数量的、且等级相同的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c97173708.spfilter,tp,LOCATION_GRAVE,0,1,ft,nil,e,tp,lv)
	-- 设置当前连锁的操作信息，表明此效果包含特殊召唤选定怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 效果处理函数（将选定的怪兽特殊召唤，并使其效果无效化，注册结束阶段破坏的效果）
function c97173708.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与此卡效果相关的目标怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()==0 then return end
	-- 获取当前可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	if ft<g:GetCount() then return end
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	local tc=g:GetFirst()
	while tc do
		-- 将目标怪兽以表侧表示特殊召唤（单步处理，不立即刷新场上状态）
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 这个效果特殊召唤的怪兽的效果无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		tc:RegisterFlagEffect(97173708,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		tc=g:GetNext()
	end
	-- 完成所有单步特殊召唤的处理，刷新场上状态
	Duel.SpecialSummonComplete()
	g:KeepAlive()
	-- 结束阶段时破坏
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCountLimit(1)
	e1:SetLabel(fid)
	e1:SetLabelObject(g)
	e1:SetCondition(c97173708.descon)
	e1:SetOperation(c97173708.desop)
	-- 注册全局延迟效果，用于在结束阶段破坏这些特殊召唤的怪兽
	Duel.RegisterEffect(e1,tp)
end
-- 过滤条件：带有当前效果唯一标识（fid）的怪兽，用于确认是否为该效果特殊召唤的怪兽
function c97173708.desfilter(c,fid)
	return c:GetFlagEffectLabel(97173708)==fid
end
-- 结束阶段破坏效果的触发条件（检查场上是否存在该效果特殊召唤的怪兽，若不存在则重置该效果）
function c97173708.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c97173708.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 结束阶段破坏效果的具体操作（筛选出场上由该效果特殊召唤的怪兽并破坏）
function c97173708.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c97173708.desfilter,nil,e:GetLabel())
	-- 因效果将这些怪兽破坏
	Duel.Destroy(tg,REASON_EFFECT)
end
