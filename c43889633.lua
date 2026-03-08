--忘却の海底神殿
-- 效果：
-- 只要这张卡在场上存在，这张卡的卡名当作「海」使用。1回合1次，可以选择自己场上表侧表示存在的1只4星以下的鱼族·海龙族·水族怪兽从游戏中除外。这个效果除外的怪兽在自己的结束阶段时在场上特殊召唤。
function c43889633.initial_effect(c)
	-- 记录该卡牌具有「海」这张卡的卡号
	aux.AddCodeList(c,22702055)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 1回合1次，可以选择自己场上表侧表示存在的1只4星以下的鱼族·海龙族·水族怪兽从游戏中除外
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43889633,1))  --"除外"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1)
	e2:SetTarget(c43889633.target)
	e2:SetOperation(c43889633.operation)
	c:RegisterEffect(e2)
	-- 使该卡的卡名在场上视为「海」使用
	aux.EnableChangeCode(c,22702055)
	-- 这个效果除外的怪兽在自己的结束阶段时在场上特殊召唤
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(43889633,2))  --"特殊召唤"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1)
	e3:SetCondition(c43889633.spcon)
	e3:SetTarget(c43889633.sptg)
	e3:SetOperation(c43889633.spop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选场上正面表示、等级4以下、种族为鱼族或海龙族或水族且可以被除外的怪兽
function c43889633.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(4) and c:IsRace(RACE_FISH+RACE_SEASERPENT+RACE_AQUA) and c:IsAbleToRemove()
end
-- 设置效果目标，选择场上正面表示、等级4以下、种族为鱼族或海龙族或水族且可以被除外的怪兽
function c43889633.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c43889633.filter(chkc) end
	-- 检查是否存在符合条件的怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(c43889633.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要除外的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择符合条件的怪兽作为除外对象
	local g=Duel.SelectTarget(tp,c43889633.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果操作信息，声明将要除外怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果处理函数，将选中的怪兽除外并记录其ID
function c43889633.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认目标怪兽存在且与当前效果相关，种族为鱼族或海龙族或水族，成功除外且位于除外区
	if tc and tc:IsRelateToEffect(e) and tc:IsRace(RACE_FISH+RACE_SEASERPENT+RACE_AQUA) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_REMOVED) then
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(43889634,RESET_EVENT+RESETS_STANDARD,0,1,fid)
	end
end
-- 过滤函数，用于筛选被除外并记录了特定ID的怪兽
function c43889633.spfilter(c,fid)
	return c:GetFlagEffect(43889634)~=0 and c:GetFlagEffectLabel(43889634)==fid
end
-- 触发条件函数，判断是否为己方回合且墓地存在符合条件的怪兽
function c43889633.spcon(e,tp,eg,ep,ev,re,r,rp)
	local fid=e:GetHandler():GetFieldID()
	-- 判断是否为己方回合且墓地存在符合条件的怪兽
	return Duel.GetTurnPlayer()==tp and Duel.IsExistingMatchingCard(c43889633.spfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,fid)
end
-- 设置特殊召唤效果的目标，获取符合条件的怪兽组
function c43889633.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local fid=e:GetHandler():GetFieldID()
	-- 获取墓地中符合条件的怪兽组
	local tg=Duel.GetMatchingGroup(c43889633.spfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil,fid)
	-- 设置效果操作信息，声明将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,1,0,0)
end
-- 特殊召唤效果处理函数，将符合条件的怪兽特殊召唤到场上
function c43889633.spop(e,tp,eg,ep,ev,re,r,rp)
	local fid=e:GetHandler():GetFieldID()
	-- 获取墓地中符合条件的怪兽组
	local tg=Duel.GetMatchingGroup(c43889633.spfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil,fid)
	if #tg>0 then
		-- 将符合条件的怪兽特殊召唤到己方场上
		Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
	end
end
