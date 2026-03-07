--サプライズ・フュージョン
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以自己场上1只表侧表示怪兽为对象，宣言种族和属性各1个才能发动。那只怪兽变成宣言的种族·属性。那之后，可以把包含那只怪兽的自己场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
-- ②：把墓地的这张卡除外才能发动。自己场上1只融合怪兽解放，把持有和那个等级相同等级的2只「惊喜衍生物」（魔法师族·暗·攻/守0）在自己场上特殊召唤。
local s,id,o=GetID()
-- 注册卡牌效果，创建①效果和②效果
function s.initial_effect(c)
	-- ①：以自己场上1只表侧表示怪兽为对象，宣言种族和属性各1个才能发动。那只怪兽变成宣言的种族·属性。那之后，可以把包含那只怪兽的自己场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"融合召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。自己场上1只融合怪兽解放，把持有和那个等级相同等级的2只「惊喜衍生物」（魔法师族·暗·攻/守0）在自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤衍生物"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RELEASE+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	-- 将此卡从墓地除外作为②效果的费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 筛选满足条件的怪兽（必须是表侧表示且种族或属性可以改变）
function s.rafilter(c)
	return c:IsFaceup() and ((RACE_ALL&~c:GetRace())~=0 or (ATTRIBUTE_ALL&~c:GetAttribute())~=0)
end
-- 处理①效果的目标选择和种族、属性宣言
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() and s.rafilter(chkc) end
	-- 检查是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(s.rafilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择目标怪兽
	local tc=Duel.SelectTarget(tp,s.rafilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	local race,att
	-- 提示玩家选择种族
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
	if ATTRIBUTE_ALL&~tc:GetAttribute()==0 then
		-- 玩家宣言种族
		race=Duel.AnnounceRace(tp,1,RACE_ALL&~tc:GetRace())
	else
		-- 玩家宣言种族
		race=Duel.AnnounceRace(tp,1,RACE_ALL)
	end
	-- 提示玩家选择属性
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	if RACE_ALL&~tc:GetRace()==0 or race==tc:GetRace() then
		-- 玩家宣言属性
		att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL&~tc:GetAttribute())
	else
		-- 玩家宣言属性
		att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL)
	end
	e:SetLabel(race,att)
end
-- 筛选场上的怪兽（必须在场上且未被效果免疫）
function s.filter1(c,e)
	return c:IsOnField() and not c:IsImmuneToEffect(e)
end
-- 筛选满足融合召唤条件的融合怪兽
function s.filter2(c,e,tp,m,ec,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,ec,chkf)
end
-- 处理①效果的发动和融合召唤
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local race,att=e:GetLabel()
	-- 获取目标怪兽
	local ec=Duel.GetFirstTarget()
	if ec:IsRelateToChain() and ec:IsFaceup() and ec:IsType(TYPE_MONSTER) then
		local cres=ec:GetRace()~=race or ec:GetAttribute()~=att
		-- 将目标怪兽的种族改为宣言的种族
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(race)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		ec:RegisterEffect(e1)
		-- 将目标怪兽的属性改为宣言的属性
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e2:SetValue(att)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		ec:RegisterEffect(e2)
		-- 刷新场上信息
		Duel.AdjustAll()
		if ec:IsControler(1-tp) or not cres then return false end
		local chkf=tp
		-- 获取融合素材组
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
		-- 检查是否存在满足条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,ec,nil,chkf)
		if not res then
			-- 获取当前连锁的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查是否存在满足条件的融合怪兽
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,ec,mf,chkf)
			end
		end
		-- 询问玩家是否进行融合召唤
		if res and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否进行融合？"
			chkf=tp
			-- 获取融合素材组
			mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
			-- 获取满足条件的融合怪兽组
			local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,ec,nil,chkf)
			local mg2=nil
			local sg2=nil
			-- 获取当前连锁的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 获取满足条件的融合怪兽组
				sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,ec,mf,chkf)
			end
			if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
				local sg=sg1:Clone()
				if sg2 then sg:Merge(sg2) end
				-- 提示玩家选择要特殊召唤的融合怪兽
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local tg=sg:Select(tp,1,1,nil)
				local tc=tg:GetFirst()
				-- 判断选择的融合怪兽是否属于第一组
				if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
					-- 选择融合素材
					local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,ec,chkf)
					tc:SetMaterial(mat1)
					-- 将融合素材送入墓地
					Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
					-- 中断当前效果
					Duel.BreakEffect()
					-- 特殊召唤融合怪兽
					Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
				elseif ce then
					-- 选择融合素材
					local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,ec,chkf)
					local fop=ce:GetOperation()
					fop(ce,e,tp,tc,mat2)
				end
				tc:CompleteProcedure()
			end
		end
	end
end
-- 筛选满足条件的融合怪兽（用于②效果）
function s.cfilter(c,tp,chk)
	return c:IsType(TYPE_FUSION) and c:IsReleasableByEffect() and (not chk
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		or (Duel.GetMZoneCount(tp,c)>1 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
			-- 检查是否可以特殊召唤衍生物
			and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,c:GetLevel(),RACE_SPELLCASTER,ATTRIBUTE_DARK)))
end
-- 处理②效果的目标选择和操作信息设置
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取可解放的卡片组
	local rg=Duel.GetReleaseGroup(tp,false,REASON_EFFECT)
	if chk==0 then return rg:IsExists(s.cfilter,1,nil,tp,true) end
	-- 设置操作信息：解放
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,0,0)
	-- 设置操作信息：召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置操作信息：特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 处理②效果的发动和特殊召唤衍生物
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取可解放的卡片组
	local rg=Duel.GetReleaseGroup(tp,false,REASON_EFFECT)
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local srg=nil
	-- 检查是否存在满足条件的融合怪兽
	local chk=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,tp,true)
	srg=rg:FilterSelect(tp,s.cfilter,1,1,nil,tp,chk)
	if srg and srg:GetCount()>0 then
		local rc=srg:GetFirst()
		local level=rc:GetLevel()
		-- 将目标怪兽解放
		if Duel.Release(rc,REASON_EFFECT)>0
			-- 检查场上是否有足够的怪兽区域
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
			-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
			and not Duel.IsPlayerAffectedByEffect(tp,59822133)
			-- 检查是否可以特殊召唤衍生物
			and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,level,RACE_SPELLCASTER,ATTRIBUTE_DARK) then
			for i=1,2 do
				-- 创建衍生物
				local token=Duel.CreateToken(tp,id+o)
				-- 设置衍生物的等级
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CHANGE_LEVEL)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
				e1:SetValue(level)
				token:RegisterEffect(e1,true)
				-- 特殊召唤衍生物
				Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
			end
			-- 完成特殊召唤
			Duel.SpecialSummonComplete()
		end
	end
end
