--V－LAN ヒドラ
-- 效果：
-- 衍生物以外的怪兽2只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的攻击力上升和这张卡互相连接的怪兽数量×300。
-- ②：以这张卡所互相连接区1只连接3以下的怪兽为对象才能发动。那只怪兽解放，那个连接标记数量的「V-LAN衍生物」（电子界族·光·1星·攻/守0）在自己场上特殊召唤。这个回合自己不能把连接标记数量和作为对象的怪兽相同的怪兽特殊召唤。
function c13536606.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，要求使用至少2个满足条件的素材
	aux.AddLinkProcedure(c,c13536606.matfilter,2)
	-- ①：这张卡的攻击力上升和这张卡互相连接的怪兽数量×300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c13536606.atkval)
	c:RegisterEffect(e1)
	-- ②：以这张卡所互相连接区1只连接3以下的怪兽为对象才能发动。那只怪兽解放，那个连接标记数量的「V-LAN衍生物」（电子界族·光·1星·攻/守0）在自己场上特殊召唤。这个回合自己不能把连接标记数量和作为对象的怪兽相同的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(13536606,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,13536606)
	e2:SetTarget(c13536606.tktg)
	e2:SetOperation(c13536606.tkop)
	c:RegisterEffect(e2)
end
-- 过滤器函数，用于判断素材是否为衍生物以外的怪兽
function c13536606.matfilter(c)
	return not c:IsLinkType(TYPE_TOKEN)
end
-- 计算攻击力上升值，为互相连接的怪兽数量乘以300
function c13536606.atkval(e,c)
	return c:GetMutualLinkedGroupCount()*300
end
-- 筛选目标怪兽的过滤器函数，判断是否满足解放条件
function c13536606.rfilter(c,tp,g)
	-- 获取目标玩家场上可用的怪兽区数量
	local ft=Duel.GetMZoneCount(tp,c)
	local lk=math.min(3,ft)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsLinkBelow(lk) and c:IsReleasableByEffect() and g:IsContains(c)
		-- 若目标玩家未被「王家长眠之谷」影响，或仅剩一个怪兽区，则满足条件
		and (ft==1 or not Duel.IsPlayerAffectedByEffect(tp,59822133))
end
-- 设置效果目标的函数，用于选择符合条件的目标怪兽
function c13536606.tktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local lg=c:GetMutualLinkedGroup()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c13536606.rfilter(chkc,tp,lg) end
	-- 检查是否有符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c13536606.rfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp,lg)
		-- 检查玩家是否可以特殊召唤衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,13536607,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_CYBERSE,ATTRIBUTE_LIGHT) end
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	-- 选择符合条件的目标怪兽
	local rg=Duel.SelectTarget(tp,c13536606.rfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp,lg)
	local ct=rg:GetFirst():GetLink()
	-- 设置操作信息，表示将特殊召唤指定数量的衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ct,0,0)
	-- 设置操作信息，表示将特殊召唤指定数量的衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,0,0)
end
-- 处理效果发动的函数
function c13536606.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	local ct=tc:GetLink()
	-- 判断目标怪兽是否有效且可被解放
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) and Duel.Release(tc,REASON_EFFECT)>0 then
		-- 获取目标玩家场上可用的怪兽区数量
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 判断是否满足特殊召唤衍生物的条件
		if ft<ct or (ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
		-- 检查玩家是否可以特殊召唤衍生物
		if not Duel.IsPlayerCanSpecialSummonMonster(tp,13536607,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_CYBERSE,ATTRIBUTE_LIGHT) then return end
		for i=1,ct do
			-- 创建一张衍生物
			local token=Duel.CreateToken(tp,13536607)
			-- 将衍生物特殊召唤到场上
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		end
		-- 完成特殊召唤步骤
		Duel.SpecialSummonComplete()
	end
	-- ②：以这张卡所互相连接区1只连接3以下的怪兽为对象才能发动。那只怪兽解放，那个连接标记数量的「V-LAN衍生物」（电子界族·光·1星·攻/守0）在自己场上特殊召唤。这个回合自己不能把连接标记数量和作为对象的怪兽相同的怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabel(ct)
	e1:SetTarget(c13536606.splimit)
	-- 注册效果，使玩家在本回合不能特殊召唤与目标怪兽连接数相同的怪兽
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的过滤器函数，禁止特殊召唤连接数等于目标怪兽连接数的怪兽
function c13536606.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLink(e:GetLabel())
end
