--コードブレイカー・ウイルスバーサーカー
-- 效果：
-- 包含「代码破坏者」怪兽的怪兽2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功时，这张卡是互相连接状态的场合才能发动。从自己的手卡·墓地选最多2只「代码破坏者」怪兽在作为连接怪兽所连接区的自己·对方场上特殊召唤。
-- ②：自己主要阶段才能发动。选最多有自己·对方场上的连接状态的「代码破坏者」怪兽数量的对方场上的魔法·陷阱卡破坏。
function c48736598.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续，素材要求为2~3只怪兽，且其中至少1只为「代码破坏者」怪兽（由lcheck判断）。
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
-- 连接召唤素材的额外判定：素材组中必须存在至少1只「代码破坏者」系列（0x13c）的连接怪兽。
function c48736598.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x13c)
end
-- ①效果的发动条件：这张卡特殊召唤成功时，自身处于互相连接状态（与至少1只怪兽互相连接）。
function c48736598.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetMutualLinkedGroupCount()>0
end
-- 特殊召唤候选的过滤条件：是「代码破坏者」怪兽，且能够被特殊召唤到自己或对方场上由连接怪兽指向的空余主要怪兽区域。
function c48736598.spfilter(c,e,tp)
	if not c:IsSetCard(0x13c) then return false end
	local ok=false
	for p=0,1 do
		-- 取得玩家p场上连接怪兽所连接的区域位掩码，并保留低8位作为可用的怪兽区域范围。
		local zone=Duel.GetLinkedZone(p)&0xff
		-- 检查玩家p场上连接区域内是否有可用空格（Duel.GetLocationCount大于0），若有则说明该侧存在可特殊召唤的位置。
		ok=ok or (Duel.GetLocationCount(p,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,p,zone))
	end
	return ok
end
-- ①效果的目标发动检查：自身与效果仍关联，并且自己的手卡·墓地存在至少1只符合条件的「代码破坏者」怪兽可供特殊召唤。
function c48736598.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e)
		-- （同时）检查自己的手卡·墓地中是否存在至少1只满足特殊召唤条件的「代码破坏者」怪兽，作为①效果的发动前提。
		and Duel.IsExistingMatchingCard(c48736598.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息，声明本连锁包含特殊召唤，目标范围为自己的手卡·墓地，预计处理1只（实际数量由处理阶段决定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ①效果处理：计算双方场上连接区域的空位总数，决定可特殊召唤的数量（最多2只，若受青眼精灵龙影响则至多1只）；从手卡·墓地选择对应数量的「代码破坏者」怪兽，并逐一选择要特殊召唤到的连接区域（自己或对方场上），最后统一特殊召唤。
function c48736598.spop(e,tp,eg,ep,ev,re,r,rp)
	local zone={}
	local flag={}
	for p=0,1 do
		-- 记录玩家p场上连接怪兽所指向的区域（低8位掩码），作为该侧可特殊召唤的候选位置。
		zone[p]=Duel.GetLinkedZone(p)&0xff
		-- 获取玩家p场上指定连接区域内的可用空格数（忽略计数），用flag_tmp接收可用区域的位掩码，以便后续求反得到不可用区域。
		local _,flag_tmp=Duel.GetLocationCount(p,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone[p])
		flag[p]=(~flag_tmp)&0x7f
	end
	-- 计算玩家0（对方或己方）场上连接区域中可用的怪兽区域数量。
	local ft1=Duel.GetLocationCount(0,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone[0])
	-- 计算玩家1（对方或己方）场上连接区域中可用的怪兽区域数量。
	local ft2=Duel.GetLocationCount(1,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone[1])
	if ft1+ft2<=0 then return end
	local ct=math.min(ft1+ft2,2)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	-- 向玩家显示选择提示：“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的手卡·墓地选择1至ct张符合条件的「代码破坏者」怪兽（已使用王家长眠之谷过滤器，排除墓地效果被无效的卡）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c48736598.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,ct,nil,e,tp)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		while tc do
			local avail_zone=0
			for p=0,1 do
				-- 同上：获取玩家p场上连接区域内可用区域的位掩码，用于计算该侧可选的特殊召唤位置。
				local _,flag_tmp=Duel.GetLocationCount(p,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone[p])
				flag[p]=(~flag_tmp)&0x7f
				if tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,p,zone[p]) then
					avail_zone=avail_zone|(flag[p]<<(p==tp and 0 or 16))
				end
			end
			-- 让玩家为当前要特殊召唤的怪兽选择一个放置的怪兽区域（可选区域为双方场上连接区域中未被占用的位置），返回选中的区域位掩码。
			local sel_zone=Duel.SelectField(tp,1,LOCATION_MZONE,LOCATION_MZONE,0x00ff00ff&(~avail_zone),tc:GetCode())
			local sump=0
			if sel_zone&0xff>0 then
				sump=tp
			else
				sump=1-tp
				sel_zone=sel_zone>>16
			end
			-- 将所选怪兽以表侧表示特殊召唤到目标玩家场上的指定区域（作为分步特殊召唤的一步，最后统一完成）。
			Duel.SpecialSummonStep(tc,0,tp,sump,false,false,POS_FACEUP,sel_zone)
			tc=g:GetNext()
		end
		-- 完成全部特殊召唤步骤，触发特殊召唤成功时的各类时点。
		Duel.SpecialSummonComplete()
	end
end
-- 用于统计数量的过滤条件：表侧表示的「代码破坏者」怪兽且处于连接状态。
function c48736598.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x13c) and c:IsLinkState()
end
-- ②效果的目标发动检查：双方场上有至少1只表侧且连接状态的「代码破坏者」怪兽，且对方场上有至少1张魔法·陷阱卡可破坏。
function c48736598.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方怪兽区域是否存在至少1只满足desfilter（表侧、字段、连接状态）的「代码破坏者」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c48736598.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- （并且）检查对方场上是否存在至少1张魔法·陷阱卡，以保证有破坏对象。
		and Duel.IsExistingMatchingCard(Card.IsType,tp,0,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
	-- 获取对方场上的全部魔法·陷阱卡，作为本次破坏效果的候选目标集合。
	local g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
	-- 设置操作信息：本效果为破坏效果，目标集合为对方场上所有魔法·陷阱卡（g），预计破坏1张，实际数量由处理时计算。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果处理：统计双方场上连接状态的「代码破坏者」怪兽数量作为可破坏数量上限，让玩家选择对方场上1至该数量的魔法·陷阱卡并破坏。
function c48736598.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 统计双方场上满足条件的「代码破坏者」怪兽数量，作为可破坏的魔法·陷阱卡张数上限。
	local ct=Duel.GetMatchingGroupCount(c48736598.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if ct<=0 then return end
	-- 向操作玩家显示选择提示：“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从对方场上选择1至ct张魔法·陷阱卡作为破坏对象。
	local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,0,LOCATION_ONFIELD,1,ct,nil,TYPE_SPELL+TYPE_TRAP)
	if g:GetCount()>0 then
		-- 为选中的卡片显示选择动画，并记录这些卡被选为破坏对象。
		Duel.HintSelection(g)
		-- 以效果原因（REASON_EFFECT）破坏所选卡片。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
