--ヴェンデット・リユニオン
-- 效果：
-- ①：把仪式召唤的手卡1只「复仇死者」仪式怪兽给对方观看。等级合计直到变成和给人观看的仪式怪兽的等级相同为止，选除外的自己的「复仇死者」怪兽任意数量里侧守备表示特殊召唤（同名卡最多1张）。那之后，那些里侧守备表示怪兽全部解放从手卡把那只仪式怪兽仪式召唤。
function c2266498.initial_effect(c)
	-- 卡片效果初始化，设置为自由连锁发动，包含特殊召唤和盖放怪兽的分类
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c2266498.target)
	e1:SetOperation(c2266498.activate)
	c:RegisterEffect(e1)
end
-- 过滤手卡中可仪式召唤的「复仇死者」怪兽
function c2266498.cfilter(c,e,tp,m,ft)
	if bit.band(c:GetType(),0x81)~=0x81 or not c:IsSetCard(0x106) or c:IsPublic()
		or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
	if c.mat_filter then
		m=m:Filter(c.mat_filter,nil,tp)
	end
	-- 设置仪式召唤等级检查函数，要求祭品等级总和等于目标怪兽等级
	aux.GCheckAdditional=aux.RitualCheckAdditional(c,c:GetLevel(),"Equal")
	local res=m:CheckSubGroup(c2266498.fselect,1,math.min(c:GetLevel(),ft),c)
	-- 清除仪式召唤等级检查函数
	aux.GCheckAdditional=nil
	return res
end
-- 选择满足条件的祭品卡片组，确保卡名不重复且等级总和符合要求
function c2266498.fselect(g,mc)
	-- 检查祭品组的等级总和是否等于目标怪兽等级
	return aux.dncheck(g) and g:CheckWithSumEqual(Card.GetRitualLevel,mc:GetLevel(),g:GetCount(),g:GetCount(),mc)
end
-- 过滤除外区中可特殊召唤的「复仇死者」怪兽
function c2266498.filter(c,e,tp)
	-- 检查目标怪兽是否为表侧表示、属于「复仇死者」卡组且可以被解放
	return c:IsFaceup() and c:IsSetCard(0x106) and Duel.IsPlayerCanRelease(tp,c,REASON_EFFECT)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 判断是否满足发动条件，检查手卡是否存在符合条件的仪式怪兽
function c2266498.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取玩家场上可用的怪兽区域数量
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 判断玩家是否可以进行特殊召唤（最多2次）
		if ft<=0 or not Duel.IsPlayerCanSpecialSummonCount(tp,2) then return false end
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 获取除外区中符合条件的「复仇死者」怪兽组
		local mg=Duel.GetMatchingGroup(c2266498.filter,tp,LOCATION_REMOVED,0,nil,e,tp)
		-- 检查是否存在符合条件的仪式怪兽
		return Duel.IsExistingMatchingCard(c2266498.cfilter,tp,LOCATION_HAND,0,1,nil,e,tp,mg,ft)
	end
	-- 设置操作信息，表示将要特殊召唤的卡牌位置
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_REMOVED)
end
-- 卡片效果发动函数，执行仪式召唤流程
function c2266498.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 判断玩家是否可以进行特殊召唤（最多2次）
	if ft<=0 or not Duel.IsPlayerCanSpecialSummonCount(tp,2) then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取除外区中符合条件的「复仇死者」怪兽组
	local mg=Duel.GetMatchingGroup(c2266498.filter,tp,LOCATION_REMOVED,0,nil,e,tp)
	-- 提示玩家选择要特殊召唤的卡牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择符合条件的仪式怪兽
	local tg=Duel.SelectMatchingCard(tp,c2266498.cfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,mg,ft)
	if tg:GetCount()>0 then
		-- 向对方确认所选仪式怪兽
		Duel.ConfirmCards(1-tp,tg)
		local tc=tg:GetFirst()
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,nil,tp)
		end
		-- 提示玩家选择要特殊召唤的卡牌
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 设置仪式召唤等级检查函数，要求祭品等级总和等于目标怪兽等级
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Equal")
		local sg=mg:SelectSubGroup(tp,c2266498.fselect,false,1,math.min(tc:GetLevel(),ft),tc)
		-- 清除仪式召唤等级检查函数
		aux.GCheckAdditional=nil
		if not sg or sg:GetCount()==0 then return end
		-- 将符合条件的祭品以里侧守备表示特殊召唤
		if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)==sg:GetCount() then
			-- 中断当前效果处理，避免错时点
			Duel.BreakEffect()
			-- 获取实际操作的卡牌组
			local og=Duel.GetOperatedGroup()
			-- 向对方确认特殊召唤的祭品
			Duel.ConfirmCards(1-tp,og)
			tc:SetMaterial(og)
			-- 将特殊召唤的祭品进行解放
			Duel.Release(og,REASON_EFFECT+REASON_RITUAL+REASON_MATERIAL)
			-- 中断当前效果处理，避免错时点
			Duel.BreakEffect()
			-- 将仪式怪兽以仪式召唤方式从手卡特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
			tc:CompleteProcedure()
		end
	end
end
