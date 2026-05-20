--パージ・レイ
-- 效果：
-- 把自己场上1只超量怪兽解放才能发动。这个回合的结束阶段时，和解放的怪兽相同种族而阶级低1阶的1只名字带有「No.」的怪兽从额外卡组特殊召唤。
function c64161630.initial_effect(c)
	-- 把自己场上1只超量怪兽解放才能发动。这个回合的结束阶段时，和解放的怪兽相同种族而阶级低1阶的1只名字带有「No.」的怪兽从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c64161630.cost)
	e1:SetTarget(c64161630.target)
	e1:SetOperation(c64161630.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：过滤自己场上可解放的、阶级大于1的超量怪兽，且额外卡组存在符合特殊召唤条件的「No.」怪兽
function c64161630.cfilter(c,e,tp)
	local rk=c:GetRank()
	return rk>1 and c:IsType(TYPE_XYZ)
		-- 检查额外卡组是否存在至少1只满足条件的「No.」怪兽（比解放怪兽阶级低1阶、相同种族、可特殊召唤）
		and Duel.IsExistingMatchingCard(c64161630.filter,tp,LOCATION_EXTRA,0,1,nil,rk-1,c:GetRace(),e,tp,c)
end
-- 过滤函数：过滤额外卡组中阶级为rk、种族为rc、名字带有「No.」的超量怪兽，且该怪兽可以特殊召唤
function c64161630.filter(c,rk,rc,e,tp,mc)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0x48)
		and c:IsRank(rk) and c:IsRace(rc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查在将解放的怪兽送去墓地后，是否有足够的额外怪兽区域空位来特殊召唤该卡
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 代价处理函数：解放自己场上1只超量怪兽，并记录其阶级和种族
function c64161630.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	-- 在发动检查阶段，检查玩家场上是否存在可解放的、满足条件的超量怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c64161630.cfilter,1,nil,e,tp) end
	-- 让玩家选择自己场上1只满足条件的超量怪兽解放
	local g=Duel.SelectReleaseGroup(tp,c64161630.cfilter,1,1,nil,e,tp)
	e:SetLabel(g:GetFirst():GetRank())
	-- 把自己场上1只超量怪兽解放才能发动。这个回合的结束阶段时，和解放的怪兽相同种族而阶级低1阶的1只名字带有「No.」的怪兽从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetLabel(g:GetFirst():GetRace())
	-- 注册一个临时效果，用于在发动代价中记录解放怪兽的种族
	Duel.RegisterEffect(e1,tp)
	e:SetLabelObject(e1)
	-- 解放选中的怪兽作为发动的代价
	Duel.Release(g,REASON_COST)
end
-- 目标处理函数：确认是否支付了代价，并重置代价标记
function c64161630.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return true
	end
end
-- 效果处理函数：注册一个在回合结束阶段触发的延迟效果，用于特殊召唤怪兽
function c64161630.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合的结束阶段时，和解放的怪兽相同种族而阶级低1阶的1只名字带有「No.」的怪兽从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetOperation(c64161630.spop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetLabel(e:GetLabel())
	e1:SetLabelObject(e:GetLabelObject())
	-- 注册在结束阶段触发的延迟效果
	Duel.RegisterEffect(e1,tp)
end
-- 延迟效果处理函数：在结束阶段从额外卡组特殊召唤1只与解放怪兽相同种族且阶级低1阶的「No.」怪兽
function c64161630.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 在结束阶段发动效果时，展示该卡片的卡图动画
	Duel.Hint(HINT_CARD,0,64161630)
	local rk=e:GetLabel()
	local rc=e:GetLabelObject():GetLabel()
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只与解放怪兽相同种族且阶级低1阶的「No.」怪兽
	local g=Duel.SelectMatchingCard(tp,c64161630.filter,tp,LOCATION_EXTRA,0,1,1,nil,rk-1,rc,e,tp)
	-- 将选中的怪兽以表侧表示特殊召唤
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
