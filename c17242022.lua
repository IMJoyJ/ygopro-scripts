--真紅眼の超越黒竜
local s,id,o=GetID()
-- 定义卡片的初始化效果，包括设置融合召唤限制、登记卡名、注册特殊召唤相关效果、免疫效果以及全局破坏检测等
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为该卡添加融合召唤手续，使用真红眼之龙（卡号74677422）以及任意1只记载真红眼之龙（卡号40235813）的怪兽作为融合素材
	aux.AddFusionProcCodeFun(c,74677422,s.mfilter,1,true,true)
	-- 在该卡效果文本中登记真红眼之龙和真红眼超越黒竜两张卡名，使它们在效果中视为同名卡
	aux.AddCodeList(c,74677422,40235813)
	-- 1回合1次，这张卡特殊召唤成功的场合才能发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(s.condition)
	e0:SetOperation(s.regop2)
	c:RegisterEffect(e0)
	-- 该卡只能通过融合召唤特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetValue(s.splimit)
	c:RegisterEffect(e2)
	-- 自己场上的「真红眼」怪兽被破坏的场合才能发动，从手卡·卡组将这张卡特殊召唤
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_EXTRA)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- 特殊召唤成功的场合才能发动，从手卡·墓地选1只等级8以下的怪兽特殊召唤
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetTarget(s.sptg2)
	e4:SetOperation(s.spop2)
	c:RegisterEffect(e4)
	-- 这张卡不受对方怪兽·魔法卡的效果
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_IMMUNE_EFFECT)
	e5:SetRange(LOCATION_MZONE)
	e5:SetValue(s.immval)
	c:RegisterEffect(e5)
	if not s.global_check then
		s.global_check=true
		-- 自己场上的「真红眼」怪兽被破坏的场合才能发动
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(s.regop)
		-- 注册全局效果，用于检测「真红眼」怪兽被破坏并设置标记
		Duel.RegisterEffect(ge1,0)
	end
end
s.material_setcode=0x3b
-- 用于融合召唤时的素材检查，确保素材中包含真红眼之龙和记载真红眼之龙的怪兽
function s.red_eyes_fusion_check(tp,sg,fc)
	-- 检查素材组是否满足真红眼之龙+记载真红眼之龙的怪兽的融合条件
	return aux.gffcheck(sg,Card.IsFusionCode,74677422,s.mfilter,nil)
end
-- 筛选因卡牌效果而被破坏的卡
function s.dcfilter(c)
	return c:IsReason(REASON_EFFECT)
end
-- 当「真红眼」怪兽因效果被破坏时，为对方玩家注册标记以满足特殊召唤条件
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if re and eg:IsExists(s.dcfilter,1,nil) and re:GetHandler():IsCode(40235813) then
		-- 为对方玩家设置标记，表示破坏事件已发生
		Duel.RegisterFlagEffect(0,id,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 筛选记载有真红眼之龙（卡号40235813）的怪兽
function s.mfilter(c)
	-- 判断该卡效果文本是否记载真红眼之龙
	return aux.IsCodeListed(c,40235813)
end
-- 限制特殊召唤只能在融合召唤且未触发过该效果的回合进行
function s.splimit(e,se,sp,st)
	-- 若为融合召唤且玩家未使用过该效果则允许特殊召唤
	return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION and Duel.GetFlagEffect(sp,id+o)==0
end
-- 检查该卡是否以融合方式特殊召唤或已被标记为满足召唤条件
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) or c:GetFlagEffect(id)>0
end
-- 在特殊召唤成功后为玩家注册标记，防止本回合再次发动同类效果
function s.regop2(e,tp,eg,ep,ev,re,r,rp)
	-- 为玩家添加标记，表示已发动过该回合的特殊召唤效果
	Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
end
-- 筛选能够作为融合素材的表侧表示、可以解放的怪兽，且额外格子里有位置
function s.hspfilter(c,tp,fc)
	return c:IsFaceup() and c:IsReleasable(REASON_MATERIAL|REASON_SPSUMMON)
		and c:IsCanBeFusionMaterial(fc,SUMMON_TYPE_SPECIAL)
		-- 检查额外卡组是否有空位用于特殊召唤
		and Duel.GetLocationCountFromEx(tp,tp,c,fc)>0
end
-- 检查是否满足特殊召唤条件：破坏标记已设置且本回合未使用过该效果，且场上有可解放的怪兽
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 若破坏标记未设置或已使用过该效果则不允许特殊召唤
	if Duel.GetFlagEffect(0,id)==0 or Duel.GetFlagEffect(tp,id+o)>0 then return false end
	-- 确认场上有符合条件的素材
	return Duel.IsExistingMatchingCard(s.hspfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp,c)
end
-- 让玩家选择要解放的怪兽作为融合素材
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取场上所有可解放的怪兽
	local g=Duel.GetMatchingGroup(s.hspfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp,c)
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 解放所选怪兽并为该卡设置标记，表示已进行过特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END,0,1)
	local g=e:GetLabelObject()
	-- 以特殊召唤为原因解放素材怪兽
	Duel.Release(g,REASON_SPSUMMON)
end
-- 筛选等级8以下且可以特殊召唤的怪兽
function s.spfilter2(c,e,tp)
	return c:IsLevelBelow(8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查场上有空位且手卡或墓地有可特殊召唤的等级8以下怪兽
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或墓地是否有符合条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 玩家选择要特殊召唤的等级8以下怪兽并进行特殊召唤
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 若没有空位则终止处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或墓地选择1只等级8以下的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 特殊召唤所选怪兽到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 返回对方玩家发动的怪兽或魔法卡效果为免疫对象
function s.immval(e,re)
	return re:GetOwnerPlayer()~=e:GetHandlerPlayer() and re:IsActivated()
		and re:IsActiveType(TYPE_MONSTER+TYPE_SPELL)
end
