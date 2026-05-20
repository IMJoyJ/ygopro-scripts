--テールズオブ妖精伝姫
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：装备怪兽的攻击力上升1000。
-- ②：1回合1次，自己主要阶段才能发动。自己的手卡·场上的怪兽作为融合素材，把1只魔法师族融合怪兽融合召唤。那个时候，对方场上的「妖精王子」也能作为融合素材。
-- ③：这张卡在墓地存在的场合才能发动。这张卡给场上1只「妖精传姬」怪兽装备。那之后，可以进行1只攻击力1850的魔法师族怪兽的召唤。
local s,id,o=GetID()
-- 初始化函数，注册卡片效果：包含装备魔法基本效果、①的攻击力上升、②的融合召唤、③的墓地装备及召唤效果
function s.initial_effect(c)
	-- 注册该卡记载了「妖精王子」（卡号19144623）的卡名信息
	aux.AddCodeList(c,19144623)
	-- 注册装备魔法的标准发动效果，可装备给场上任意表侧表示怪兽
	aux.AddEquipSpellEffect(c,true,true,Card.IsFaceup,nil)
	-- ①：装备怪兽的攻击力上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(1000)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己主要阶段才能发动。自己的手卡·场上的怪兽作为融合素材，把1只魔法师族融合怪兽融合召唤。那个时候，对方场上的「妖精王子」也能作为融合素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"融合召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.fsptg)
	e2:SetOperation(s.fspop)
	c:RegisterEffect(e2)
	-- ③：这张卡在墓地存在的场合才能发动。这张卡给场上1只「妖精传姬」怪兽装备。那之后，可以进行1只攻击力1850的魔法师族怪兽的召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"装备效果"
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.eqtg)
	e3:SetOperation(s.eqop)
	c:RegisterEffect(e3)
end
-- 过滤对方场上表侧表示且可作为融合素材的「妖精王子」
function s.filter0(c)
	return c:IsFaceup() and c:IsCode(19144623) and c:IsCanBeFusionMaterial()
end
-- 过滤不受当前效果影响的融合素材卡片
function s.filter1(c,e)
	return c and not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中可以进行融合召唤的魔法师族融合怪兽
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_SPELLCASTER) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 融合召唤效果的发动准备与合法性检测（Target阶段）
function s.fsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		local chkf=tp
		-- 获取己方可用的融合素材，并过滤掉不受效果影响的卡
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
		-- 获取对方场上满足条件的「妖精王子」作为可选融合素材
		local mg2=Duel.GetMatchingGroup(s.filter0,tp,0,LOCATION_MZONE,nil):Filter(s.filter1,nil,e)
		mg1:Merge(mg2)
		-- 检查额外卡组是否存在可以使用当前素材融合召唤的魔法师族融合怪兽
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 检查是否存在适年的连锁素材效果（如「连锁素材」）
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁素材效果下是否存在可融合召唤的怪兽
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置效果处理信息为从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 融合召唤效果的具体处理逻辑（Operation阶段）
function s.fspop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 重新获取并过滤己方可用的融合素材
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 重新获取并过滤对方场上可作为素材的「妖精王子」
	local mg2=Duel.GetMatchingGroup(s.filter0,tp,0,LOCATION_MZONE,nil):Filter(s.filter1,nil,e)
	mg1:Merge(mg2)
	-- 获取当前素材下可以融合召唤的怪兽集合
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 重新获取适用的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果下可以融合召唤的怪兽集合
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规融合方式（而非连锁素材效果）进行融合召唤
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择用于融合召唤该怪兽的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选定的融合素材送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的特殊召唤不与送墓同时处理
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤的方式表侧表示特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 在使用连锁素材效果时，让玩家选择对应的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 过滤场上表侧表示的「妖精传姬」怪兽
function s.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1db)
end
-- 墓地装备及召唤效果的发动准备与合法性检测（Target阶段）
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	-- 检查己方魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查场上是否存在可以装备的「妖精传姬」怪兽
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 设置效果处理信息为这张卡离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
	-- 设置效果处理信息为将这张卡作为装备卡装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,0,0)
end
-- 过滤手卡或场上可以进行通常召唤、且攻击力为1850的魔法师族怪兽
function s.sumfilter(c)
	return c:IsSummonable(true,nil) and c:IsRace(RACE_SPELLCASTER) and c:IsAttack(1850)
end
-- 墓地装备及召唤效果的具体处理逻辑（Operation阶段）
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍与连锁相关，以及魔陷区是否有空位，若不满足则结束处理
	if not c:IsRelateToChain() or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 检查该卡是否受到「王家之谷的眠谷」的影响
	if not aux.NecroValleyFilter()(c) then return end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家选择场上1只表侧表示的「妖精传姬」怪兽
	local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 选中目标怪兽并显示选择动画
	Duel.HintSelection(g)
	local tc=g:GetFirst()
	-- 将这张卡作为装备卡装备给选中的怪兽
	if tc and Duel.Equip(tp,c,tc)
		-- 检查手卡或场上是否存在可以召唤的攻击力1850的魔法师族怪兽
		and Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
		-- 询问玩家是否进行召唤
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否进行召唤？"
		-- 中断当前效果处理，使后续的召唤不与装备同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
		-- 让玩家选择1只满足条件的攻击力1850的魔法师族怪兽
		local sg=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
		if sg:GetCount()>0 then
			-- 忽略每回合的通常召唤次数限制，对选中的怪兽进行通常召唤
			Duel.Summon(tp,sg:GetFirst(),true,nil)
		end
	end
end
