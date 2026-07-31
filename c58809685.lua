--エルフェンノーツ～継唱のクウォートレイン～
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己的中央的主要怪兽区域的怪兽不能用对方的效果除外。
-- ②：从自己的手卡·场上把这张卡以外的1张魔法·陷阱卡送去墓地，宣言1～4的任意等级才能发动。把持有宣言的等级的1只「极花之大耀圣衍生物」（植物族·调整·炎·攻/守0）在自己场上特殊召唤。只要这个效果特殊召唤的衍生物存在，自己不是「耀圣」怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：注册①中央主怪兽区域防效果除外防护、②送墓魔陷特召「极花之大耀圣衍生物」的效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己的中央的主怪兽区域的怪兽不能用对方的效果除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_REMOVE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetTarget(s.rmlimit)
	c:RegisterEffect(e2)
	-- ②：从自己的手卡·场上把这张卡以外的1张魔法·陷阱卡送去墓地，宣言1～4的任意等级才能发动。把持有宣言的等级的1只「极花之大耀圣衍生物」（植物族·调整·炎·攻/守0）在自己场上特殊召唤。只要这个效果特殊召唤的衍生物存在，自己不是「耀圣」怪兽不能从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 防除外限制条件：目标卡控制者为己方、在中央主怪兽区域（序号2），且因对方卡的效果除外（非重定向除外）
function s.rmlimit(e,c,rp,r,re)
	local tp=e:GetHandlerPlayer()
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:GetSequence()==2
		and r&REASON_EFFECT~=0 and r&REASON_REDIRECT==0 and rp==1-tp
end
-- Cost过滤条件：手卡·场上的魔法·陷阱卡，且满足送墓后有可用怪兽区域及可作为Cost
function s.cfilter(c,tp)
	-- 判断卡片是否为魔法·陷阱卡，且送去墓地时己方场上有空余怪兽区域并能作为Cost送去墓地
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and Duel.GetMZoneCount(tp,c)>0 and c:IsAbleToGraveAsCost()
end
-- ②效果发动Cost：从手卡·场上把这张卡以外的1张魔法·陷阱卡送去墓地
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检查：手卡/场上是否存在除自身外可送墓的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler(),tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手卡/场上选择1张除自身以外的魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,e:GetHandler(),tp)
	-- 将选中的魔法·陷阱卡作为Cost送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- ②效果发动准备：检查可特召的衍生物等级选项，宣言1~4的等级并设置特召操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local lvt={}
	for i=1,4 do
		-- 检查玩家是否能在己方场上特殊召唤指定等级的「极花之大耀圣衍生物」
		if Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0x1d8,TYPES_TOKEN_MONSTER,0,0,i,RACE_PLANT,ATTRIBUTE_FIRE) then
			lvt[i]=i
		end
	end
	if chk==0 then
		if e:IsCostChecked() then
			return next(lvt)~=nil
		else
			-- 非Cost检查时判断己方主怪兽区域是否有空位
			return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				and next(lvt)~=nil
		end
	end
	local pc=1
	for i=1,4 do
		if lvt[i] then lvt[i]=nil lvt[pc]=i pc=pc+1 end
	end
	lvt[pc]=nil
	-- 提示玩家选择要宣言的等级
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	-- 由玩家选择宣言1～4中可用的等级，并将宣言的数值保存至Label
	e:SetLabel(Duel.AnnounceNumber(tp,table.unpack(lvt)))
	-- 设置连锁操作信息：生成1张衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置连锁操作信息：特殊召唤1只怪兽到己方场上
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
-- ②效果处理：生成宣言等级的「极花之大耀圣衍生物」表侧表示特召，并注册额外卡组特召限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	-- 检查己方怪兽区域是否有空位，无空位则终止处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 检查是否仍能特殊召唤指定等级的衍生物，不能则终止处理
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0x1d8,TYPES_TOKEN_MONSTER,0,0,lv,RACE_PLANT,ATTRIBUTE_FIRE) then return end
	-- 创建「极花之大耀圣衍生物」卡片对象
	local token=Duel.CreateToken(tp,id+o)
	-- 赋予衍生物效果：修改等级为玩家宣言的数值
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
	e1:SetValue(lv)
	token:RegisterEffect(e1,true)
	-- 将衍生物以表侧表示特殊召唤（分步处理）
	Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	-- 只要这个效果特殊召唤的衍生物存在，自己不是「耀圣」怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetAbsoluteRange(tp,1,0)
	e2:SetTarget(s.splimit)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	token:RegisterEffect(e2,true)
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 特召限制过滤条件：限制自己不能从额外卡组特殊召唤非「耀圣」怪兽
function s.splimit(e,c)
	return not c:IsSetCard(0x1d8) and c:IsLocation(LOCATION_EXTRA)
end
