--コードブレイカー・ウイルスバーサーカー
-- 效果：
-- 包含「代码破坏者」怪兽的怪兽2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功时，这张卡是互相连接状态的场合才能发动。从自己的手卡·墓地选最多2只「代码破坏者」怪兽在作为连接怪兽所连接区的自己·对方场上特殊召唤。
-- ②：自己主要阶段才能发动。选最多有自己·对方场上的连接状态的「代码破坏者」怪兽数量的对方场上的魔法·陷阱卡破坏。
function c48736598.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，要求使用2到3个满足过滤条件的怪兽作为连接素材
	aux.AddLinkProcedure(c,nil,2,3,c48736598.lcheck)
	-- ①：这张卡特殊召唤成功时，这张卡是互相连接状态的场合才能发动。从自己的手卡·墓地选最多2只「代码破坏者」怪兽在作为连接怪兽所连接区的自己·对方场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48736598,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,48736598)
	e1:SetCost(c48736598.spcon)
	e1:SetTarget(c48736598.sptg)
	e1:SetOperation(c48736598.spop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。选最多有自己·对方场上的连接状态的「代码破坏者」怪兽数量的对方场上的魔法·陷阱卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48736598,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,48736599)
	e2:SetTarget(c48736598.destg)
	e2:SetOperation(c48736598.desop)
	c:RegisterEffect(e2)
end
-- 连接召唤时的过滤条件函数，确保所选素材中至少包含一只「代码破坏者」系列的怪兽
function c48736598.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x13c)
end
-- 效果发动条件函数，判断当前卡片是否处于互相连接状态
function c48736598.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetMutualLinkedGroupCount()>0
end
-- 特殊召唤目标筛选函数，检查手牌或墓地中的「代码破坏者」怪兽是否能在指定区域被特殊召唤
function c48736598.spfilter(c,e,tp)
	if not c:IsSetCard(0x13c) then return false end
	local ok=false
	for p=0,1 do
		-- 获取玩家p的连接区域
		local zone=Duel.GetLinkedZone(p)&0xff
		-- 检查指定区域是否有足够的空位用于特殊召唤
		ok=ok or (Duel.GetLocationCount(p,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,p,zone))
	end
	return ok
end
-- 效果发动时的判定函数，判断是否满足发动条件
function c48736598.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e)
		-- 检查手牌或墓地中是否存在至少一张符合条件的「代码破坏者」怪兽
		and Duel.IsExistingMatchingCard(c48736598.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息，告知连锁处理中将要特殊召唤的卡的数量和位置
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果执行函数，实现从手牌或墓地选择并特殊召唤「代码破坏者」怪兽的过程
function c48736598.spop(e,tp,eg,ep,ev,re,r,rp)
	local zone={}
	local flag={}
	for p=0,1 do
		-- 获取玩家p的连接区域
		zone[p]=Duel.GetLinkedZone(p)&0xff
		-- 获取玩家p在指定区域的可用空位数量
		local _,flag_tmp=Duel.GetLocationCount(p,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone[p])
		flag[p]=(~flag_tmp)&0x7f
	end
	-- 获取玩家0的可用怪兽区空格数
	local ft1=Duel.GetLocationCount(0,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone[0])
	-- 获取玩家1的可用怪兽区空格数
	local ft2=Duel.GetLocationCount(1,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone[1])
	if ft1+ft2<=0 then return end
	local ct=math.min(ft1+ft2,2)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌或墓地中选择符合条件的「代码破坏者」怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c48736598.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,ct,nil,e,tp)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		while tc do
			local avail_zone=0
			for p=0,1 do
				-- 获取玩家p在指定区域的可用空位数量
				local _,flag_tmp=Duel.GetLocationCount(p,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone[p])
				flag[p]=(~flag_tmp)&0x7f
				if tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,p,zone[p]) then
					avail_zone=avail_zone|(flag[p]<<(p==tp and 0 or 16))
				end
			end
			-- 让玩家选择一个场地用于特殊召唤
			local sel_zone=Duel.SelectField(tp,1,LOCATION_MZONE,LOCATION_MZONE,0x00ff00ff&(~avail_zone),tc:GetCode())
			local sump=0
			if sel_zone&0xff>0 then
				sump=tp
			else
				sump=1-tp
				sel_zone=sel_zone>>16
			end
			-- 执行单张怪兽的特殊召唤步骤
			Duel.SpecialSummonStep(tc,0,tp,sump,false,false,POS_FACEUP,sel_zone)
			tc=g:GetNext()
		end
		-- 完成所有特殊召唤步骤
		Duel.SpecialSummonComplete()
	end
end
-- 破坏对象筛选函数，判断是否为「代码破坏者」系列且处于连接状态的怪兽
function c48736598.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x13c) and c:IsLinkState()
end
-- 效果发动时的判定函数，判断是否满足发动条件
function c48736598.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少一只「代码破坏者」系列且处于连接状态的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c48736598.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 检查对方场地上是否存在魔法或陷阱卡
		and Duel.IsExistingMatchingCard(Card.IsType,tp,0,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
	-- 获取对方场上的所有魔法·陷阱卡
	local g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
	-- 设置操作信息，告知连锁处理中将要破坏的卡的数量和位置
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果执行函数，实现选择并破坏对方场上魔法·陷阱卡的过程
function c48736598.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 统计己方场上的「代码破坏者」系列且处于连接状态的怪兽数量
	local ct=Duel.GetMatchingGroupCount(c48736598.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if ct<=0 then return end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择指定数量的魔法·陷阱卡进行破坏
	local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,0,LOCATION_ONFIELD,1,ct,nil,TYPE_SPELL+TYPE_TRAP)
	if g:GetCount()>0 then
		-- 显示被选为对象的卡
		Duel.HintSelection(g)
		-- 执行破坏操作，将目标卡破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
