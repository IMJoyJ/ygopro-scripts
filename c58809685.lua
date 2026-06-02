--エルフェンノーツ～継唱のクウォートレイン～
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己的中央的主要怪兽区域的怪兽不能用对方的效果除外。
-- ②：从自己的手卡·场上把这张卡以外的1张魔法·陷阱卡送去墓地，宣言1～4的任意等级才能发动。把持有宣言的等级的1只「极花之大耀圣衍生物」（植物族·调整·炎·攻/守0）在自己场上特殊召唤。只要这个效果特殊召唤的衍生物存在，自己不是「耀圣」怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 注册魔陷卡的发动效果e1、效果①（中央怪兽区除外抗性e2）以及效果②（特召衍生物e3）
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
-- 抗性生效的目标判定：必须是自己控制的位于中央主要怪兽区域（序列为2）的怪兽，且由对方玩家的效果除外
function s.rmlimit(e,c,rp,r,re)
	local tp=e:GetHandlerPlayer()
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:GetSequence()==2
		and r&REASON_EFFECT~=0 and r&REASON_REDIRECT==0 and rp==1-tp
end
-- Cost过滤条件：手卡·场上除了这张卡以外的魔法·陷阱卡，且将其送入墓地后有可用的怪兽区域
function s.cfilter(c,tp)
	-- 判定卡片是否是魔法·陷阱卡，且将其送入墓地后玩家场上的怪兽区域空格数大于0，且能送去墓地
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and Duel.GetMZoneCount(tp,c)>0 and c:IsAbleToGraveAsCost()
end
-- 效果②的Cost处理：从自己的手卡·场上把这张卡以外的1张魔法·陷阱卡送去墓地
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为效果Cost发动检查（chk==0），判定己方手卡或场上是否存在能送去墓地的其他魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler(),tp) end
	-- 发送系统提示：请选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手卡或场上选择1张这张卡以外的魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,e:GetHandler(),tp)
	-- 将选中的魔法·陷阱卡送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果②的发动判定与宣言等级：检查玩家是否可以特殊召唤对应等级的衍生物，并让玩家宣言一个1至4的等级，最后设置操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local lvt={}
	for i=1,4 do
		-- 判定玩家是否可以特殊召唤所宣言的特定等级、植物族、炎属性、攻击力/守备力为0的衍生物怪兽
		if Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0x1d8,TYPES_TOKEN_MONSTER,0,0,i,RACE_PLANT,ATTRIBUTE_FIRE) then
			lvt[i]=i
		end
	end
	if chk==0 then
		if e:IsCostChecked() then
			return next(lvt)~=nil
		else
			-- 判定当前己方场上可用的怪兽区域空格数是否大于0
			return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				and next(lvt)~=nil
		end
	end
	local pc=1
	for i=1,4 do
		if lvt[i] then lvt[i]=nil lvt[pc]=i pc=pc+1 end
	end
	lvt[pc]=nil
	-- 发送系统提示：请选择要宣言的等级
	Duel.Hint(HINT_SELECTMSG,tp,HINGMSG_LVRANK)
	-- 让玩家宣言一个1～4的任意等级，并把该等级存储在效果标签中
	e:SetLabel(Duel.AnnounceNumber(tp,table.unpack(lvt)))
	-- 设置操作信息：特殊召唤衍生物怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：将怪兽特殊召唤到自己场上
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
-- 效果②的效果处理：在自己场上特殊召唤1只持有宣言等级的「极花之大耀圣衍生物」，并对其注册额外卡组特召限制效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	-- 检查己方场上可用的怪兽区空格数是否少于等于0
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 或者无法特殊召唤所宣言等级的「极花之大耀圣衍生物」，若是则不处理
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0x1d8,TYPES_TOKEN_MONSTER,0,0,lv,RACE_PLANT,ATTRIBUTE_FIRE) then return end
	-- 生成卡片密码对应的「极花之大耀圣衍生物」
	local token=Duel.CreateToken(tp,id+o)
	-- 把持有宣言的等级的1只「极花之大耀圣衍生物」在自己场上特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
	e1:SetValue(lv)
	token:RegisterEffect(e1,true)
	-- 将衍生物以表侧表示特殊召唤到玩家场上
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
	-- 完成怪兽特殊召唤的一系列分解处理步骤
	Duel.SpecialSummonComplete()
end
-- 额外卡组特召限制过滤条件：非「耀圣」怪兽且从额外卡组特殊召唤
function s.splimit(e,c)
	return not c:IsSetCard(0x1d8) and c:IsLocation(LOCATION_EXTRA)
end
