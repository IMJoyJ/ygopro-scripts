--K9－LC拘束解除
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只「K9」超量怪兽或者5阶超量怪兽为对象才能发动。和那只自己怪兽卡名不同的1只「K9」超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
-- ②：自己的「K9」怪兽进行战斗的回合的战斗阶段结束时才能发动。墓地的这张卡在自己场上盖放。
local s,id,o=GetID()
-- 注册卡名①②效果，①为通常发动，②为战斗阶段结束时触发的效果
function s.initial_effect(c)
	-- ①：以自己场上1只「K9」超量怪兽或者5阶超量怪兽为对象才能发动。和那只自己怪兽卡名不同的1只「K9」超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己的「K9」怪兽进行战斗的回合的战斗阶段结束时才能发动。墓地的这张卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		-- 创建一个全局持续效果，用于记录战斗中使用的K9怪兽
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLED)
		ge1:SetOperation(s.checkop)
		-- 将全局持续效果注册到游戏环境
		Duel.RegisterEffect(ge1,0)
	end
end
-- 战斗阶段结束时，检查是否有K9怪兽参与战斗并记录标识
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击方怪兽
	local at=Duel.GetAttackTarget()
	-- 获取防守方怪兽
	local ar=Duel.GetAttacker()
	if at and at:IsSetCard(0x1cb) then
		-- 若攻击方为K9怪兽，则为其控制者注册标识效果
		Duel.RegisterFlagEffect(at:GetControler(),id,RESET_PHASE+PHASE_END,0,1)
	end
	if ar and ar:IsSetCard(0x1cb) then
		-- 若防守方为K9怪兽，则为其控制者注册标识效果
		Duel.RegisterFlagEffect(ar:GetControler(),id,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 过滤满足条件的怪兽：场上正面表示的超量怪兽，且为K9或5阶
function s.filter1(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and (c:IsSetCard(0x1cb) or c:IsRank(5))
		-- 检查该怪兽是否满足成为超量素材的条件
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查是否存在满足条件的额外卡组怪兽可特殊召唤
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetCode())
end
-- 过滤满足条件的额外卡组怪兽：为K9且卡号不同，可作为超量素材，可特殊召唤
function s.filter2(c,e,tp,mc,code)
	return c:IsSetCard(0x1cb) and not c:IsCode(code) and mc:IsCanBeXyzMaterial(c)
		-- 检查该怪兽是否可特殊召唤且场上存在足够召唤空间
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 设置效果目标选择函数，选择符合条件的场上怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter1(chkc,e,tp) end
	-- 判断是否满足发动条件：场上存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp)end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择效果对象
	Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置操作信息，表示将特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 设置效果发动后的处理函数，处理特殊召唤操作
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查目标怪兽是否满足成为超量素材的条件
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL)
		or tc:IsFacedown() or not tc:IsRelateToChain() or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetCode())
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将目标怪兽的叠放卡叠放到召唤怪兽上
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将目标怪兽叠放到召唤怪兽上
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将召唤怪兽特殊召唤到场上
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
-- 设置效果发动条件，判断是否为战斗阶段结束时且有K9怪兽参与战斗
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否有K9怪兽参与战斗
	return Duel.GetFlagEffect(tp,id)>0
end
-- 设置效果发动后的处理函数，处理盖放操作
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置操作信息，表示将卡盖放到场上
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 设置效果发动后的处理函数，处理盖放操作
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查卡是否在连锁中且未被王家长眠之谷影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将卡盖放到场上
		Duel.SSet(tp,c)
	end
end
