--バリアンズ・ホープ
local s,id,o=GetID()
-- 初始化卡片效果：注册①手牌·墓地特召及等级统一效果，与②墓地除外重叠超量素材效果
function s.initial_effect(c)
	-- 初始化卡片效果：注册①手牌·墓地特召「巴利安」/「混沌」超量怪兽及等级统一效果（魔法发动）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 初始化卡片效果：注册②除外墓地自身，给场上超量怪兽重叠「No.」素材效果（启动效果）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- ②效果Cost：将墓地的此卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.mattg)
	e2:SetOperation(s.matop)
	c:RegisterEffect(e2)
end
-- 特召怪兽过滤条件：「巴利安」怪兽或「混沌」超量怪兽且可特殊召唤
function s.spfilter(c,e,tp)
	return (c:IsSetCard(0x87) or c:IsSetCard(0x1e3) and c:IsType(TYPE_XYZ)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 等级修改目标过滤：场上表侧表示的「巴利安」怪兽，且当前等级不等于选定的等级
function s.cfilter1(c,lv)
	return c:IsFaceup() and c:IsSetCard(0x87)
		and c:IsLevelAbove(1) and not c:IsLevel(lv)
end
-- 等级参考卡过滤：场上·墓地表侧表示的「巴利安」怪兽，且场上存在与其等级不同的「巴利安」怪兽
function s.cfilter2(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x87)
		and c:IsLevelAbove(1)
		-- 检查场上是否存在可以变更为该怪兽等级的其他「巴利安」怪兽
		and Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_MZONE,0,1,nil,c:GetLevel())
end
-- ①效果发动准备：设置从手牌·墓地特召怪兽的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：怪兽区有空位且手牌·墓地存在满足条件的怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌或墓地是否存在符合特召条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁操作信息：从手牌或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ①效果处理：从手牌·墓地特召目标怪兽，成功后可选场上·墓地1只「巴利安」怪兽将场上其他「巴利安」怪兽等级变为相同
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理检查：怪兽区域是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌或墓地选择1只满足条件的怪兽（受王谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 成功特殊召唤怪兽后的后续分支条件检查
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查场上·墓地是否存在可用作等级参考的「巴利安」怪兽
		and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp)
		-- 询问玩家是否要统一场上「巴利安」怪兽的等级
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		-- 分隔效果处理（特召与修改等级不同时进行）
		Duel.BreakEffect()
		-- 提示玩家选择作为等级参考的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 从场上或墓地选择1只「巴利安」怪兽
		local sg=Duel.SelectMatchingCard(tp,s.cfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tp)
		-- 在场上/视觉上高亮显示选中的参考卡
		Duel.HintSelection(sg)
		local lv=sg:GetFirst():GetLevel()
		-- 获取自己场上所有等级不等于该等级的「巴利安」怪兽
		local tg=Duel.GetMatchingGroup(s.cfilter1,tp,LOCATION_MZONE,0,nil,lv)
		-- 遍历匹配到的怪兽并逐一修改其等级
		for lc in aux.Next(tg) do
			-- 动态注册效果：将怪兽等级临时变更至选定参考卡等级
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(lv)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			lc:RegisterEffect(e1)
		end
	end
end
-- 素材附加目标过滤：自己场上表侧表示的超量怪兽
function s.matfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 重叠素材卡过滤条件：「No.」超量怪兽且能够作为超量素材
function s.mtfilter(c)
	return c:IsSetCard(0x48) and c:IsType(TYPE_XYZ) and c:IsCanOverlay()
end
-- ②效果发动准备与目标选择：选择自己场上1只超量怪兽作为重叠对象
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.matfilter(chkc) end
	-- 发动条件检查：自己场上存在超量怪兽
	if chk==0 then return Duel.IsExistingTarget(s.matfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查额外卡组或墓地是否存在可作为素材的「No.」超量怪兽
		and Duel.IsExistingMatchingCard(s.mtfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要附加素材的表侧表示怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只超量怪兽作为对象
	Duel.SelectTarget(tp,s.matfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果处理：从额外卡组·墓地选择1只「No.」超量怪兽，叠放在目标怪兽下作为超量素材
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选中的目标超量怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsType(TYPE_MONSTER) and tc:IsRelateToChain() and not tc:IsImmuneToEffect(e) then
		-- 提示玩家选择要作为超量素材的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		-- 从额外卡组或墓地选择1只满足条件的「No.」超量怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.mtfilter),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的怪兽重叠在目标卡之下作为超量素材
			Duel.Overlay(tc,g)
		end
	end
end
