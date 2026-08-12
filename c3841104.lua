--解層竜ストラティアエ
-- 效果：
-- 包含恐龙族怪兽的怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡连接召唤的场合才能发动。这张卡的攻击力上升那些作为连接素材的恐龙族怪兽的原本攻击力合计数值的一半。
-- ②：自己主要阶段才能发动。自己的场上·墓地的怪兽作为融合素材除外，把1只恐龙族融合怪兽融合召唤。这个效果的发动后，直到回合结束时自己不是恐龙族怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 初始化效果：设置苏生限制并添加连接召唤手续，注册①的连接召唤成功时攻击力上升效果、素材检查效果以及②的1回合1次的融合召唤起动效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：用2只满足条件的怪兽（其中至少1只恐龙族）作为连接素材
	aux.AddLinkProcedure(c,nil,2,2,s.lcheck)
	-- ①：这张卡连接召唤的场合才能发动。这张卡的攻击力上升那些作为连接素材的恐龙族怪兽的原本攻击力合计数值的一半。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"攻击力上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.atkcon)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	-- 作为连接素材的恐龙族怪兽的原本攻击力合计数值（检查素材）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ②：自己主要阶段才能发动。自己的场上·墓地的怪兽作为融合素材除外，把1只恐龙族融合怪兽融合召唤。这个效果的发动后，直到回合结束时自己不是恐龙族怪兽不能从额外卡组特殊召唤。（这个卡名的②的效果1回合只能使用1次）
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"融合召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.fsptg)
	e3:SetOperation(s.fspop)
	c:RegisterEffect(e3)
end
-- 连接素材过滤函数：检查连接素材组中是否存在至少1只恐龙族怪兽
function s.lcheck(g)
	return g:IsExists(Card.IsLinkRace,1,nil,RACE_DINOSAUR)
end
-- ①效果的发动条件：这张卡是连接召唤的场合，且作为连接素材的恐龙族怪兽原本攻击力合计大于0
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) and e:GetLabel()>0
end
-- 素材检查函数：遍历这张卡的连接素材，把其中恐龙族怪兽的原本攻击力（文本记载攻击力）合计数值记录下来，供①效果使用
function s.valcheck(e,c)
	local g=c:GetMaterial()
	local atk=0
	-- 依次遍历连接素材中的每一张卡
	for tc in aux.Next(g) do
		-- 只统计作为连接素材的恐龙族怪兽（并且通过covcheck检查其在场上时已被确认）
		if tc:IsLinkRace(RACE_DINOSAUR) and aux.covcheck(tc) then
			local tatk=tc:GetTextAttack()
			if tatk>0 then atk=atk+tatk end
		end
	end
	e:GetLabelObject():SetLabel(atk)
end
-- ①效果的处理：取记录的攻击力合计数值，计算其一半（向上取整），给这张卡注册永续的攻击力上升效果
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsFaceup() and c:IsRelateToChain()) then return end
	local atk=e:GetLabel()
	if atk==0 then return end
	atk=math.ceil(atk/2)
	-- 这张卡的攻击力上升那些作为连接素材的恐龙族怪兽的原本攻击力合计数值的一半。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
-- 场上素材过滤：在场上、可以除外且不免疫此效果的卡
function s.filter1(c,e)
	return c:IsOnField() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 融合怪兽过滤：恐龙族融合怪兽，满足附加条件（若有），可以被融合召唤，且能从给定素材组中选出融合素材
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_DINOSAUR) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 墓地素材过滤：可以作为融合素材且可以除外的怪兽
function s.filter3(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- ②效果的目标设定：收集自己场上·墓地可作为融合素材并可以除外的怪兽，检查额外卡组是否存在可以用这些素材融合召唤的恐龙族融合怪兽（含连锁素材的场合），并设置特殊召唤和除外的操作信息
function s.fsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 取得自己手卡·场上可用的融合素材，并过滤为在场上且可以除外的卡
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
		-- 取得自己墓地中可以作为融合素材且可以除外的怪兽
		local mg2=Duel.GetMatchingGroup(s.filter3,tp,LOCATION_GRAVE,0,nil)
		mg1:Merge(mg2)
		-- 检查额外卡组是否存在至少1只可以用上述素材组融合召唤的恐龙族融合怪兽
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 取得自己受到的连锁素材效果（如融合魔法给予的额外素材来源）
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 若常规素材无法融合召唤，则改用连锁素材提供的素材组检查是否存在可以融合召唤的恐龙族融合怪兽
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：将从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息：将除外自己场上·墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- ②效果的处理：收集场上·墓地（墓地受王家长眠之谷过滤）的融合素材，让玩家选择1只要融合召唤的恐龙族融合怪兽，把素材除外并将其融合召唤，之后注册直到回合结束时自己不是恐龙族怪兽不能从额外卡组特殊召唤的限制
function s.fspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	-- 取得自己手卡·场上可用的融合素材，并过滤为在场上且可以除外的卡
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 取得自己墓地中可以作为融合素材且可以除外、且不受王家长眠之谷影响的怪兽
	local mg2=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter3),tp,LOCATION_GRAVE,0,nil)
	mg1:Merge(mg2)
	-- 检索额外卡组中可以用这些素材融合召唤的恐龙族融合怪兽
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 取得自己受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 用连锁素材提供的素材组检索额外卡组中可以融合召唤的恐龙族融合怪兽
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 向玩家提示请选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断选中的融合怪兽是否用常规素材召唤：若不同时在连锁素材组中，或玩家选择不使用连锁素材的效果，则进入常规融合召唤处理
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从常规素材组中选择该融合怪兽的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材以效果·融合素材原因表侧除外
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断效果处理，使之后的特殊召唤与除外视为不同时处理
			Duel.BreakEffect()
			-- 将该恐龙族融合怪兽以融合召唤方式在自己场上表侧表示特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce~=nil then
			-- 让玩家从连锁素材提供的素材组中选择该融合怪兽的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		if tc:IsLocation(LOCATION_MZONE) then
			tc:CompleteProcedure()
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是恐龙族怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 把不能特殊召唤的限制效果注册为玩家的全局效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制对象：额外卡组中不是恐龙族的怪兽
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsRace(RACE_DINOSAUR)
end
