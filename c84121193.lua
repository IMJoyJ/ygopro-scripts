--コードブレイカー・ウイルスソードマン
-- 效果：
-- 效果怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功时，这张卡是互相连接状态的场合才能发动。从自己的手卡·卡组·墓地选1只「代码破坏者·零日」在作为连接怪兽所连接区的自己·对方场上特殊召唤。
-- ②：这张卡被对方破坏送去墓地的回合的结束阶段才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c84121193.initial_effect(c)
	-- 为这张卡添加连接召唤手续：效果怪兽2只。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤成功时，这张卡是互相连接状态的场合才能发动。从自己的手卡·卡组·墓地选1只「代码破坏者·零日」在作为连接怪兽所连接区的自己·对方场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84121193,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,84121193)
	e1:SetCost(c84121193.spcon1)
	e1:SetTarget(c84121193.sptg1)
	e1:SetOperation(c84121193.spop1)
	c:RegisterEffect(e1)
	-- ②：这张卡被对方破坏送去墓地的回合的结束阶段才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c84121193.regcon1)
	e2:SetOperation(c84121193.regop1)
	c:RegisterEffect(e2)
	-- ②：这张卡被对方破坏送去墓地的回合的结束阶段才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(84121193,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,84121194)
	e3:SetCondition(c84121193.spcon2)
	e3:SetTarget(c84121193.sptg2)
	e3:SetOperation(c84121193.spop2)
	c:RegisterEffect(e3)
end
-- 检查这张卡是否处于互相连接状态。
function c84121193.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetMutualLinkedGroupCount()>0
end
-- 过滤手卡·卡组·墓地的「代码破坏者·零日」，且该卡能特殊召唤到双方场上连接怪兽所连接的区域。
function c84121193.spfilter(c,e,tp)
	if not c:IsCode(8662794) then return false end
	local ok=false
	for p=0,1 do
		-- 获取玩家p场上所有连接怪兽所连接的区域（主要怪兽区域）。
		local zone=Duel.GetLinkedZone(p)&0xff
		-- 检查玩家p场上连接怪兽所连接的区域是否有可用的怪兽区域空格。
		ok=ok or (Duel.GetLocationCount(p,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,p,zone))
	end
	return ok
end
-- 效果①的发动准备与合法性检查（检查自身是否在场，以及手卡·卡组·墓地是否存在可特殊召唤的「代码破坏者·零日」）。
function c84121193.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e)
		-- 检查自己的手卡、卡组、墓地是否存在至少1只满足特殊召唤条件的「代码破坏者·零日」。
		and Duel.IsExistingMatchingCard(c84121193.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示将从手卡、卡组或墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果①的运行空间：让玩家从手卡·卡组·墓地选择1只「代码破坏者·零日」，并选择双方场上连接怪兽所连接的可用区域进行特殊召唤。
function c84121193.spop1(e,tp,eg,ep,ev,re,r,rp)
	local zone={}
	local flag={}
	for p=0,1 do
		-- 获取玩家p场上连接怪兽所连接的区域。
		zone[p]=Duel.GetLinkedZone(p)&0xff
		-- 获取玩家p场上连接怪兽所连接区域的可用空格标记（按位表示）。
		local _,flag_tmp=Duel.GetLocationCount(p,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone[p])
		flag[p]=(~flag_tmp)&0x7f
	end
	-- 获取自己场上连接怪兽所连接区域的可用空格数量。
	local ft1=Duel.GetLocationCount(0,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone[0])
	-- 获取对方场上连接怪兽所连接区域的可用空格数量。
	local ft2=Duel.GetLocationCount(1,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone[1])
	if ft1+ft2<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡、卡组、墓地选择1只满足条件的「代码破坏者·零日」（受王家长眠之谷影响）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c84121193.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		if tc then
			local avail_zone=0
			for p=0,1 do
				if tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,p,zone[p]) then
					avail_zone=avail_zone|(flag[p]<<(p==tp and 0 or 16))
				end
			end
			-- 提示玩家选择要特殊召唤到的区域。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
			-- 让玩家在双方场上可用的连接区域中选择1个格子（通过对可用区域取反来禁用不可用区域）。
			local sel_zone=Duel.SelectDisableField(tp,1,LOCATION_MZONE,LOCATION_MZONE,0x00ff00ff&(~avail_zone))
			local sump=0
			if sel_zone&0xff>0 then
				sump=tp
			else
				sump=1-tp
				sel_zone=sel_zone>>16
			end
			-- 将选中的「代码破坏者·零日」以表侧表示特殊召唤到所选玩家的所选区域。
			Duel.SpecialSummon(tc,0,tp,sump,false,false,POS_FACEUP,sel_zone)
		end
	end
end
-- 检查这张卡是否是被对方破坏并从自己场上送去自己墓地。
function c84121193.regcon1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and rp==1-tp and c:IsPreviousControler(tp)
end
-- 为这张卡注册一个在回合结束前有效的标记，用于记录其被对方破坏送去墓地的事实。
function c84121193.regop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(84121193,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 检查这张卡是否在本回合被对方破坏送去墓地（是否存在对应的标记）。
function c84121193.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(84121193)>0
end
-- 效果②的发动准备与合法性检查（检查自己场上是否有空位，以及自身是否能特殊召唤）。
function c84121193.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示将从墓地特殊召唤这张卡自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_GRAVE)
end
-- 效果②的运行空间：将这张卡从墓地特殊召唤，并添加“从场上离开的场合除外”的限制。
function c84121193.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡自身以表侧表示特殊召唤，若特殊召唤成功则执行后续处理。
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
			e1:SetValue(LOCATION_REMOVED)
			c:RegisterEffect(e1)
		end
	end
end
