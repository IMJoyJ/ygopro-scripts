--バリアンズ・ホープ
local s,id,o=GetID()
-- 初始化卡片效果：注册①手卡·墓地特召「七皇」/「异晶人」超量怪兽及统一等级效果、②墓地除外自身给场上超量怪兽重叠额外/墓地「No.」素材效果
function s.initial_effect(c)
	-- ①：从自己的手卡·墓地选1只「七皇」超量怪兽或者「异晶人」超量怪兽特殊召唤。那之后，可以选包含自己场上·墓地1只「七皇」怪兽在内的自己场上的全部「七皇」怪兽的等级变成与选的1只相同的等级。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只超量怪兽为对象才能发动。把自己的额外卡组·墓地的1只「No.」超量怪兽在作为对象的怪兽下面重叠作为超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- ②效果Cost：将墓地的自身除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.mattg)
	e2:SetOperation(s.matop)
	c:RegisterEffect(e2)
end
-- 特殊召唤过滤条件：属于「七皇」（0x87）或「异晶人」（0x1e3）的超量怪兽，且可特殊召唤
function s.spfilter(c,e,tp)
	return (c:IsSetCard(0x87) or c:IsSetCard(0x1e3) and c:IsType(TYPE_XYZ)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 等级变更目标过滤条件：自己场上表侧表示、等级不等于参考等级lv的「七皇」怪兽
function s.cfilter1(c,lv)
	return c:IsFaceup() and c:IsSetCard(0x87)
		and c:IsLevelAbove(1) and not c:IsLevel(lv)
end
-- 参考卡过滤条件：场上/墓地表侧表示且有等级的「七皇」怪兽，且场上存在可改变等级的其他「七皇」怪兽
function s.cfilter2(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x87)
		and c:IsLevelAbove(1)
		-- 检查场上是否存在与该卡等级不同的其他「七皇」怪兽
		and Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_MZONE,0,1,nil,c:GetLevel())
end
-- ①效果发动准备：检查怪兽区空位及手卡/墓地可特召目标，设置特殊召唤操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查主要怪兽区域是否有可用空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或墓地是否存在符合条件的「七皇」或「异晶人」超量怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁操作信息：从手卡·墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ①效果处理：从手卡/墓地特召1只目标超量怪兽，其后可选定1只「七皇」怪兽将其等级统一赋予场上所有「七皇」怪兽
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 主要怪兽区域无空位时终止处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·墓地选择1只满足条件的「七皇」或「异晶人」超量怪兽（受王谷过滤影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 检查目标怪兽是否成功表侧表示特殊召唤
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查场上/墓地是否存在可作为等级参考的「七皇」怪兽
		and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp)
		-- 询问玩家是否发动变更等级的后续效果
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		-- 连接效果块（分隔特殊召唤与等级变更的处理）
		Duel.BreakEffect()
		-- 提示玩家选择作为等级参考的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 从场上·墓地选择1只「七皇」怪兽作为等级参考
		local sg=Duel.SelectMatchingCard(tp,s.cfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tp)
		-- 高亮显示选中的参考卡片
		Duel.HintSelection(sg)
		local lv=sg:GetFirst():GetLevel()
		-- 获取自己场上所有等级与参考卡不同的表侧表示「七皇」怪兽
		local tg=Duel.GetMatchingGroup(s.cfilter1,tp,LOCATION_MZONE,0,nil,lv)
		-- 遍历选中的每只「七皇」怪兽
		for lc in aux.Next(tg) do
			-- 给选中的怪兽注册等级变更效果，使其等级变成参考卡的等级
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(lv)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			lc:RegisterEffect(e1)
		end
	end
end
-- 重叠对象过滤条件：场上表侧表示的超量怪兽
function s.matfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 超量素材过滤条件：「No.」（0x48）超量怪兽且可以作为超量素材
function s.mtfilter(c)
	return c:IsSetCard(0x48) and c:IsType(TYPE_XYZ) and c:IsCanOverlay()
end
-- ②效果发动准备：选择自己场上1只表侧超量怪兽作为对象，并检查额外/墓地是否存在可重叠的「No.」超量怪兽
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.matfilter(chkc) end
	-- 检查自己场上是否存在可选择的表侧超量怪兽
	if chk==0 then return Duel.IsExistingTarget(s.matfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查额外卡组或墓地是否存在可以重叠的「No.」超量怪兽
		and Duel.IsExistingMatchingCard(s.mtfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要作为对象的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从自己场上选择1只表侧表示超量怪兽作为对象
	Duel.SelectTarget(tp,s.matfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果处理：从额外卡组·墓地选择1只「No.」超量怪兽，在选中的对象怪兽下面重叠作为超量素材
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取设定的目标超量怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsType(TYPE_MONSTER) and tc:IsRelateToChain() and not tc:IsImmuneToEffect(e) then
		-- 提示玩家选择要作为超量素材的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		-- 从额外卡组·墓地选择1只「No.」超量怪兽（受王谷过滤影响）
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.mtfilter),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡作为超量素材重叠在目标怪兽下面
			Duel.Overlay(tc,g)
		end
	end
end
