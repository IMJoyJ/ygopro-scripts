--エルフェンノーツ～継唱のクウォートレイン～
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己的中央的主要怪兽区域的怪兽不能用对方的效果除外。
-- ②：从自己的手卡·场上把这张卡以外的1张魔法·陷阱卡送去墓地，宣言1～4的任意等级才能发动。把持有宣言的等级的1只「极花之大耀圣衍生物」（植物族·调整·炎·攻/守0）在自己场上特殊召唤。只要这个效果特殊召唤的衍生物存在，自己不是「耀圣」怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 初始化并注册3个效果：永续魔陷通用的发动许可空效果、中央主怪兽区怪兽不能用对方效果除外的永续效果、以及发动后特殊召唤衍生物的诱发即时效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己的中央的主要怪兽区域的怪兽不能用对方的效果除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_REMOVE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetTarget(s.rmlimit)
	c:RegisterEffect(e2)
	-- ②：从自己的手卡·场上把这张卡以外的1张魔法·陷阱卡送去墓地，宣言1～4的任意等级才能发动。把持有宣言的等级的1只「极花之大耀圣衍生物」（植物族·调整·炎·攻/守0）在自己场上特殊召唤。这个卡名的②的效果1回合只能使用1次。
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
-- 限定不能除外的范围：只有自己场上中央的主要怪兽区域（序列2）的怪兽，且是对方的效果造成的除外（不包含改变去向）才被禁止
function s.rmlimit(e,c,rp,r,re)
	local tp=e:GetHandlerPlayer()
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:GetSequence()==2
		and r&REASON_EFFECT~=0 and r&REASON_REDIRECT==0 and rp==1-tp
end
-- 代价卡的过滤条件函数：是魔法·陷阱卡、其离场后自己场上仍有可用的主怪兽区、且可以作为代价送去墓地
function s.cfilter(c,tp)
	-- 该卡是魔法·陷阱卡、将其送去墓地后自己仍有空的主怪兽区、且该卡可以作为代价送去墓地
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and Duel.GetMZoneCount(tp,c)>0 and c:IsAbleToGraveAsCost()
end
-- 效果代价处理：确认存在符合条件的卡后，从自己的手卡·场上把这张卡以外的1张魔法·陷阱卡送去墓地作为代价
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测时，检查自己的手卡·场上是否存在这张卡以外满足代价条件的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler(),tp) end
	-- 向玩家显示「请选择要送去墓地的卡」的选卡提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己的手卡·场上选择1张这张卡以外满足条件的魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,e:GetHandler(),tp)
	-- 把选择的卡作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 目标处理：枚举1～4级中能够特殊召唤衍生物的等级，确认主怪兽区有空位且存在可宣言的等级后，让玩家宣言等级并记录，同时设置生成衍生物和特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local lvt={}
	for i=1,4 do
		-- 检查能否把等级i的「极花之大耀圣衍生物」（植物族·炎属性）特殊召唤到自己场上
		if Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0x1d8,TYPES_TOKEN_MONSTER,0,0,i,RACE_PLANT,ATTRIBUTE_FIRE) then
			lvt[i]=i
		end
	end
	if chk==0 then
		if e:IsCostChecked() then
			return next(lvt)~=nil
		else
			-- 检查自己的主要怪兽区域是否有可用的空格
			return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				and next(lvt)~=nil
		end
	end
	local pc=1
	for i=1,4 do
		if lvt[i] then lvt[i]=nil lvt[pc]=i pc=pc+1 end
	end
	lvt[pc]=nil
	-- 向玩家显示宣言等级的选择提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	-- 让玩家从可宣言的等级中宣言1个数字，并将宣言的等级保存到标签中供效果处理使用
	e:SetLabel(Duel.AnnounceNumber(tp,table.unpack(lvt)))
	-- 设置操作信息：本连锁将生成1只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：自己将特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
-- 效果处理开始：取出宣言的等级，若主怪兽区没有空位或不能特殊召唤该等级的衍生物，则中止处理
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	-- 检查自己的主要怪兽区域是否还有可用的空格
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 检查能否把宣言等级的衍生物特殊召唤到自己场上，不能则中止效果处理
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0x1d8,TYPES_TOKEN_MONSTER,0,0,lv,RACE_PLANT,ATTRIBUTE_FIRE) then return end
	-- 在自己场上创建「极花之大耀圣衍生物」的卡实体
	local token=Duel.CreateToken(tp,id+o)
	-- 把持有宣言的等级的1只「极花之大耀圣衍生物」（植物族·调整·炎·攻/守0）在自己场上特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
	e1:SetValue(lv)
	token:RegisterEffect(e1,true)
	-- 将衍生物以表侧表示分步特殊召唤到自己场上
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
	-- 结束分步特殊召唤流程，完成本次特殊召唤
	Duel.SpecialSummonComplete()
end
-- 特殊召唤限制条件：不是「耀圣」系列卡且位于额外卡组的怪兽不能特殊召唤
function s.splimit(e,c)
	return not c:IsSetCard(0x1d8) and c:IsLocation(LOCATION_EXTRA)
end
